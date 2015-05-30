#!/bin/sh

# update at 2015-05-03 by Bill
ver_nginx=1.7.6
ver_luajit=2.0.3
ver_ngx_devel_kit=0.2.19
ver_ngx_lua_module=0.9.13rc1

mkdir -p /tmp/ngx_lua_waf
cd /tmp/ngx_lua_waf

# step 1, install LuaJIT
if [ ! -x "LuaJIT-$ver_luajit.tar.gz" ]; then
wget "http://luajit.org/download/LuaJIT-$ver_luajit.tar.gz"
fi
tar zxvf "LuaJIT-$ver_luajit.tar.gz"
cd "LuaJIT-$ver_luajit"
make
make install PREFIX=/usr/local/lj2
ln -s /usr/local/lj2/lib/libluajit-5.1.so.2 /lib/
cd /tmp/ngx_lua_waf

# step 2, get ngx devel kit
if [ ! -x "v$ver_ngx_devel_kit.zip" ]; then
wget "https://github.com/simpl/ngx_devel_kit/archive/v$ver_ngx_devel_kit.zip"
fi
unzip "v$ver_ngx_devel_kit.zip"

# step 3, get nginx lua module
if [ ! -x "v$ver_ngx_lua_module.zip" ]; then
wget "https://github.com/chaoslawful/lua-nginx-module/archive/v$ver_ngx_lua_module.zip"
fi
unzip "v$ver_ngx_lua_module.zip"

# step 4, install PCRE
cd /tmp/ngx_lua_waf
# apt-get update && apt-get upgrade -y && apt-get install libpcre3 libpcre3-dev -y
apt-get install libpcre3 libpcre3-dev -y

# if [ ! -x "pcre-8.10.tar.gz" ]; then
# wget http://blog.s135.com/soft/linux/nginx_php/pcre/pcre-8.10.tar.gz
# fi
# tar zxvf pcre-8.10.tar.gz
# cd pcre-8.10/
# ./configure
# make && make install
# cd ..

# step 5, install nginx
if [ ! -x "nginx-$ver_nginx.tar.gz" ]; then
wget "http://nginx.org/download/nginx-$ver_nginx.tar.gz"
fi
tar -xzvf "nginx-$ver_nginx.tar.gz"
cd "nginx-$ver_nginx/"
export LUAJIT_LIB=/usr/local/lj2/lib/
export LUAJIT_INC=/usr/local/lj2/include/luajit-2.0/
./configure --user=www --group=www --prefix=/usr/local/nginx/ --with-http_stub_status_module --with-http_sub_module --with-http_gzip_static_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module  --add-module=../ngx_devel_kit-$ver_ngx_devel_kit/ --add-module=../lua-nginx-module-$ver_ngx_lua_module/
make -j8
make install 
# rm -rf /tmp/ngx_lua_waf

# copy nginx_lua_waf conf
mkdir /usr/local/nginx/conf/waf
cd /usr/local/nginx/conf/waf
wget https://github.com/loveshell/ngx_lua_waf/archive/master.zip --no-check-certificate
unzip master.zip
# mv ngx_lua_waf-master/* /usr/local/nginx/conf/waf

# clear tmp files
rm -rf ngx_lua_waf-master
rm -rf /tmp/ngx_lua_waf
mkdir -p /data/logs/hack
chmod -R 775 /data/logs/hack
