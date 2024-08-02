#!/bin/sh
docker pull nginx
docker run --rm \
  -p 0.0.0.0:8880:80 \
  -p 0.0.0.0:443:443 \
  -v "$PWD/../../testFiles/":/usr/share/nginx/html/ \
  -v "$PWD/index.html":/usr/share/nginx/html/index.html \
  -v "$PWD/nginx_conf/default.conf.onl":/etc/nginx/conf.d/default.conf \
  -v "$PWD/nginx_conf/nginx.conf.onl":/etc/nginx/nginx.conf \
  -v "$PWD/nginx_conf/certs/cert.pem":/etc/nginx/cert.pem \
  -v "$PWD/nginx_conf/certs/key.pem":/etc/nginx/key.pem \
 --name nginx \
  -t nginx
