# nginx-lua-waf

## 使用

进入源码目录 nginx-lua-waf， 执行下列命令来创建 `bilxio/nginx-lua-waf` 映像：
```
docker build -t bilxio/nginx-lua-waf .
```
运行映像，并将访问至 8080 端口的请求都转发至 "10.10.10.9:80"：
```
docker run -d -p 8080:80 -e PROXY_REDIRECT_IP=10.10.10.9 \
	bilxio/nginx-lua-waf
```

## 配置

> 拷贝 src/waf/config.lua，再修改。通过 -v 参数挂载此文件到 docker container 中。

例如：
```
cp src/waf/config.lua /tmp/config.lua

docker run -d -p 8080:80 -e PROXY_REDIRECT_IP=10.10.10.9 \
	-v /tmp/config.lua:/usr/local/nginx/conf/waf/config.lua \
	bilxio/nginx-lua-waf
```

### 开启防 CC 攻击
修改 src/waf/config.lua, 将 `CCDeny="off"` 改为 `CCDeny="on"`

### CC 控频
修改 src/waf/config.lua, 将 `CCrate="100/60"` 改为你需要的配置。 "100/60" 意思是
60秒内单一 IP 来源访问不能超过 100 次。

### IP 白名单

### IP 黑名单

### 修改 GET 防护规则

### 修改 POST 防护规则

### 修改 COOKIE 防护规则

### 修改 URL 防护规则

## 致谢

- WAF 部分的 Lua 脚本移植自这里 [https://github.com/loveshell/ngx_lua_waf]
