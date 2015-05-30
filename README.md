# nginx-lua-waf

## Usage

To create the image `bilxio/nginx-lua-waf`, execute the following command on the
nginx-lua-waf folder:
```
docker build -t bilxio/nginx-lua-waf .
```

To run the image and forward the port 8080 to "10.10.10.9:80":
```
docker run -d -p 8080:80 -e PROXY_REDIRECT_IP=10.10.10.9 \
	bilxio/nginx-lua-waf
```

## Thanks

- Core Lua scripts migrated from here [https://github.com/loveshell/ngx_lua_waf]
