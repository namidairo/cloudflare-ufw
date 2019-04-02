#!/bin/sh

DIR="$(dirname $(readlink -f $0))"
cd $DIR
wget https://www.cloudflare.com/ips-v4 -O ips-v4.tmp
wget https://www.cloudflare.com/ips-v6 -O ips-v6.tmp
mv ips-v4.tmp ips-v4
mv ips-v6.tmp ips-v6

for cfip in `cat ips-v4`; do ufw allow from $cfip; done
for cfip in `cat ips-v6`; do ufw allow from $cfip; done

ufw reload > /dev/null

# Nginx

# Empty out old config
truncate -s 0 /etc/nginx/conf.d/cloudflare.conf

# Append to config
for cfip in `cat ips-v4`; do echo "set_real_ip_from $cfip;" >> /etc/nginx/conf.d/cloudflare.conf; done
for cfip in `cat ips-v6`; do echo "set_real_ip_from $cfip;" >> /etc/nginx/conf.d/cloudflare.conf; done
echo "real_ip_header CF-Connecting-IP;" >> /etc/nginx/conf.d/cloudflare.conf;

# Reload nginx
service nginx reload

# OTHER EXAMPLE RULES
# Examples to retrict to port 80
#for cfip in `cat ips-v4`; do ufw allow from $cfip to any port 80 proto tcp; done
#for cfip in `cat ips-v6`; do ufw allow from $cfip to any port 80 proto tcp; done

# Examples to restrict to port 443
#for cfip in `cat ips-v4`; do ufw allow from $cfip to any port 443 proto tcp; done
#for cfip in `cat ips-v6`; do ufw allow from $cfip to any port 443 proto tcp; done
