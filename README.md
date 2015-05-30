# nginx-lua-waf

## Usage

To build the image `bilxio/nginx-lua-waf` by your self, execute the following command on the nginx-lua-waf folder:

```
docker build -t bilxio/nginx-lua-waf .
```

Or, just pull it,

```
docker pull bilxio/nginx-lua-waf
```

To run the image and forward the port 8080 to "10.10.10.9:80":

```
docker run -d -p 8080:80 -e PROXY_REDIRECT_IP=10.10.10.9 \
	bilxio/nginx-lua-waf
```

## Configuration

> Copy & modify src/waf/config.lua. Mount the modified config to container by `-v` param

For example：

```
cp src/waf/config.lua /tmp/config.lua

docker run -d -p 8080:80 -e PROXY_REDIRECT_IP=10.10.10.9 \
	-v /tmp/config.lua:/usr/local/nginx/conf/waf/config.lua \
	bilxio/nginx-lua-waf
```

### Enable "CC" attack defense
Open src/waf/config.lua, change `CCDeny="off"` to `CCDeny="on"`

### "CC" defense rate
Open src/waf/config.lua, change `CCrate="100/60"` to some reasonable value. "100/60" means limit to 100 requests during 60 seconds.

### Want more?
please ref [loveshell/ngx_lua_waf](https://github.com/loveshell/ngx_lua_waf)

## Thanks

- Core Lua scripts migrated from here [loveshell/ngx_lua_waf](https://github.com/loveshell/ngx_lua_waf)
