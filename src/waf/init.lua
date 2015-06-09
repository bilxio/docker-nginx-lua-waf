require 'config'

local match = string.match
local ngxmatch = ngx.re.match
local unescape = ngx.unescape_uri
local get_headers = ngx.req.get_headers
local optionIsOn = function (options) return options == "on" and true or false end

logPath = CONFIG.LOG_DIR
rulePath = CONFIG.RULE_PATH

isUrlDeny = optionIsOn(CONFIG.URL_DENY)
isPostCheck = optionIsOn(CONFIG.POST_MATCH)
isCookieCheck = optionIsOn(CONFIG.COOKIE_MATCH)
isWhiteCheck = optionIsOn(CONFIG.WHITE_MODULE)
-- PathInfoFix = optionIsOn(PathInfoFix)
isAttackLog = optionIsOn(CONFIG.ATTACK_LOG)
isCcDeny = optionIsOn(CONFIG.CC_DENY)
isRedirect = optionIsOn(CONFIG.REDIRECT)

function getClientIp()
  IP = ngx.req.get_headers()["X-Real-IP"]
  if IP == nil then
    IP  = ngx.var.remote_addr
  end
  if IP == nil then
    IP  = "unknown"
  end
  return IP
end

function write(logfile,msg)
  local fd = io.open(logfile,"ab")
  if fd == nil then return end
  fd:write(msg)
  fd:flush()
  fd:close()
end

function log(method,url,data,ruletag)
  if isAttackLog then
    local realIp = getClientIp()
    local ua = ngx.var.http_user_agent
    local servername=ngx.var.server_name
    local time=ngx.localtime()
    if ua  then
      line = realIp.." ["..time.."] \""..method.." "..servername..url.."\" \""..data.."\"  \""..ua.."\" \""..ruletag.."\"\n"
    else
      line = realIp.." ["..time.."] \""..method.." "..servername..url.."\" \""..data.."\" - \""..ruletag.."\"\n"
    end
    local filename = logPath..'/'..servername.."_"..ngx.today().."_sec.log"
    write(filename,line)
  end
end

------------------------------------规则读取函数-------------------------------------------------------------------

function read_rule(var)
  file = io.open(rulePath..'/'..var,"r")
  if file==nil then
    return
  end
  t = {}
  for line in file:lines() do
    table.insert(t,line)
  end
  file:close()
  return(t)
end

urlrules = read_rule('url')
argsrules = read_rule('args')
uarules = read_rule('user-agent')
wturlrules  = read_rule('whiteurl')
postrules = read_rule('post')
ckrules = read_rule('cookie')

function say_html()
  if isRedirect then
    ngx.header.content_type = "text/html"
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say(CONFIG.WARNING_HTML)
    ngx.exit(ngx.status)
  end
end

function say_json()
  if isRedirect then
    ngx.header.content_type = "application/json"
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say(CONFIG.WARNING_JSON)
    ngx.exit(ngx.status)
  end
end

function whiteurl()
  if isWhiteCheck then
    if wturlrules ~=nil then
      for _,rule in pairs(wturlrules) do
        if ngxmatch(ngx.var.uri,rule,"isjo") then
          return true
        end
      end
    end
  end
  return false
end

function fileExtCheck(ext)
  local items = Set(BLACK_FILE_EXT)
  ext=string.lower(ext)
  if ext then
    for rule in pairs(items) do
      if ngxmatch(ext,rule,"isjo") then
        log('POST',ngx.var.request_uri,"-","file attack with ext "..ext)
        say_html()
      end
    end
  end
  return false
end

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function args()
  for _,rule in pairs(argsrules) do
    local args = ngx.req.get_uri_args()
    for key, val in pairs(args) do
      if type(val) == 'table' then
        if val ~= false then
          data = table.concat(val, " ")
        end
      else
        data=val
      end
      if data and type(data) ~= "boolean" and rule ~= "" and ngxmatch(unescape(data),rule,"isjo") then
        log('GET',ngx.var.request_uri,"-",rule)
        say_html()
        return true
      end
    end
  end
  return false
end

function url()
  if isUrlDeny then
    for _,rule in pairs(urlrules) do
      if rule ~="" and ngxmatch(ngx.var.request_uri,rule,"isjo") then
        log('GET',ngx.var.request_uri,"-",rule)
        say_html()
        return true
      end
    end
  end
  return false
end

function ua()
  local ua = ngx.var.http_user_agent
  if ua ~= nil then
    for _,rule in pairs(uarules) do
      if rule ~="" and ngxmatch(ua,rule,"isjo") then
        log('UA',ngx.var.request_uri,"-",rule)
        say_html()
        return true
      end
    end
  end
  return false
end

function body(data)
  for _,rule in pairs(postrules) do
    if rule ~="" and data~="" and ngxmatch(unescape(data),rule,"isjo") then
      log('POST',ngx.var.request_uri,data,rule)
      say_html()
      return true
    end
  end
  return false
end

function cookie()
  local ck = ngx.var.http_cookie
  if isCookieCheck and ck then
    for _,rule in pairs(ckrules) do
      if rule ~="" and ngxmatch(ck,rule,"isjo") then
        log('Cookie',ngx.var.request_uri,"-",rule)
        say_html()
        return true
      end
    end
  end
  return false
end

function denycc()
  if isCcDeny then
    local uri = ngx.var.uri
    -- local args = ngx.var.args
    local CCcount = tonumber(string.match(CONFIG.CC_RATE,'(.*)/'))
    local CCseconds = tonumber(string.match(CONFIG.CC_RATE,'/(.*)'))
    local token = getClientIp()..uri
    local limit = ngx.shared.limit
    local req,_ = limit:get(token)
    if req then
      if req > CCcount then
        ngx.header.content_type = "application/json"
        ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE
        ngx.say('{"message":"Yo, visit too frequently."}')
        ngx.exit(ngx.status)
        return true
      else
        limit:incr(token, 1)
      end
    else
      limit:set(token, 1, CCseconds)
    end
  end
  return false
end

function get_boundary()
  local header = get_headers()["content-type"]
  if not header then
    return nil
  end

  if type(header) == "table" then
    header = header[1]
  end

  local m = match(header, ";%s*boundary=\"([^\"]+)\"")
  if m then
    return m
  end

  return match(header, ";%s*boundary=([^\",;]+)")
end

function whiteip()
  if next(CONFIG.IP_LIST_WHITE) ~= nil then
    for _,ip in pairs(CONFIG.IP_LIST_WHITE) do
      if getClientIp() == ip then
        return true
      end
    end
  end
  return false
end

function blockip()
  if next(CONFIG.IP_LIST_BLOCK) ~= nil then
    for _,ip in pairs(CONFIG.IP_LIST_BLOCK) do
      if getClientIp() == ip then
        ngx.exit(403)
        return true
      end
    end
  end
  return false
end
