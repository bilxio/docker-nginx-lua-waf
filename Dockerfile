FROM bilxio/ubuntu:14.04

MAINTAINER Xiong Zhengdong <haibxz@gmail.com>

ENV PROXY_REDIRECT_IP 12.34.56.78

RUN echo "#########################" && \
    echo " install LuaJIT" && \
    echo "#########################" && \
    cd /usr/local/src && \
		wget "http://luajit.org/download/LuaJIT-2.0.3.tar.gz" && \
    tar -zxvf LuaJIT-2.0.3.tar.gz && \
    cd LuaJIT-2.0.3 && \
    make && \
    make PREFIX=/usr/local/luajit install && \
    adduser nginx && \
    export LUAJIT_LIB=/usr/local/luajit/lib && \
    export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0 && \
    cd /usr/local/src && \
    git clone git://github.com/simpl/ngx_devel_kit.git && \
    git clone git://github.com/chaoslawful/lua-nginx-module.git && \
    wget http://downloads.sourceforge.net/project/pcre/pcre/8.36/pcre-8.36.tar.bz2 && \
    tar xf pcre-8.36.tar.bz2 && \
    echo "#########################" && \
    echo " install nginx" && \
    echo "#########################" && \
    wget http://nginx.org/download/nginx-1.7.6.tar.gz && \
    tar xf nginx-1.7.6.tar.gz && \
    cd nginx-1.7.6 && \
    ./configure --prefix=/usr/local/nginx \
      --user=nginx \
      --group=nginx \
      --with-http_ssl_module \
      --with-http_gzip_static_module \
      --with-http_realip_module \
      --with-pcre=/usr/local/src/pcre-8.36 \
      --add-module=/usr/local/src/ngx_devel_kit \
      --add-module=/usr/local/src/lua-nginx-module \
      --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" && \
    make && \
    make install


# copy all WAF scripts to nginx conf directory
ADD src/waf/ /usr/local/nginx/conf/waf/


ADD src/nginx/waf.conf /etc/nginx/waf.conf
ADD src/nginx/localhost.conf /etc/nginx/localhost.conf
ADD src/nginx/nginx.conf /usr/local/nginx/conf/nginx.conf

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

# create a directory to store hack logs
RUN mkdir -p /usr/local/nginx/logs/hack/ && \
  chown nginx:nginx /usr/local/nginx/logs/hack && \
  chmod 766 /usr/local/nginx/logs/hack

VOLUME ["/usr/local/nginx", "/var/log/nginx"]

EXPOSE 80
CMD ["/entrypoint.sh"]
