#!/bin/bash
#/etc/init.d/crond start

# replace REDIRECT URL
sed -i s/'<proxy_redirect_ip>'/${PROXY_REDIRECT_IP}/g /etc/nginx/localhost.conf

/usr/local/nginx/sbin/nginx &
echo "=> nginx started!"
echo ""


# dont need this line if `run.sh` executed
#/usr/bin/tail -f /dev/null


# initialize SSH
/bin/bash /run.sh
