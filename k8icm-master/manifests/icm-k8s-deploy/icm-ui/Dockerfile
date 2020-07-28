FROM 100.2.30.190/incloudos-docker/icm-base:latest

USER root

COPY icm /usr/local/inspurnode/icm

RUN cd /usr/local/inspurnode/icm \
  && tar xf node_modules.tar \
  && rm -rf node_modules.tar \
  && cd /usr/local/inspurnode/icm/server \
  && tar xf node_modules.tar \
  && rm -rf node_modules.tar \
  && cd /usr/local/inspurnode/icm \
  && node bin/deploy-server.js \
  && node bin/deploy-vue.js

RUN chmod +x /usr/local/inspurnode/pm2/bin/pm2 /usr/local/inspurnode/node-v7.10.0-linux-x64/bin/node /usr/local/inspurnode/bin/start.sh
WORKDIR /usr/local/inspurnode/bin/

ENTRYPOINT [ "/bin/bash","-c","/usr/local/inspurnode/bin/start.sh && tail -f /dev/null" ]
