# README

## About tools

"ngx_lua_waf" is a good WAF framework, I like it very much. I made some
changes for the "install.sh" to update the related softwares to the latest
version.


## How to use these tools

- step 1, install nginx service
"nginx" is a start-stop-daemon script. Just put it into /etc/init.d, then
execute `update-rc.d nginx defaults`. After that, nginx will auto startup
when server up.


- step 2, copy log-rotate config
"nginx-logrotate" is a script for the logrotate for nginx. Copy it to the
dir "/etc/logrotate.d" and rename to "nginx"


- step 3 [optional], copy "nginx.conf" to "/usr/local/nginx/conf"