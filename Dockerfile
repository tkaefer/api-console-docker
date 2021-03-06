FROM alpine
MAINTAINER Tobias Kaefer <tobias+apcnsldckr@tkaefer.de>

#
# install Node & Git
#
RUN apk add --update nodejs git \
		&& rm -rf /var/cache/apk/*

#
# install Bower & Grunt
#
RUN npm install -g bower grunt-cli

#
# define working directory.
#
WORKDIR /data

#
# download the specified (API_CONSOLE_VERSION) version of RAML api:Console
#
RUN git clone https://github.com/mulesoft/api-console.git /data \
        && mkdir /data/dist/apis \
        && mv /data/dist/examples/simple.raml /data/dist/apis/main.raml \
        && rm -rf /data/dist/examples \
        && rm -rf /data/src \
        && rm -rf /data/test \
        && rm -rf /data/.git

#
# install modules and dependencies with NPM and Bower
#
RUN npm install \
        && sed -i 's/crypto-js\.googlecode\.com\/files/storage\.googleapis\.com\/google-code-archive-downloads\/v2\/code\.google\.com\/crypto-js/g' /data/bower.json \
        && bower install --production --allow-root \
        && npm cache clean \
        && bower cache clean --allow-root

EXPOSE 9000
EXPOSE 35729

#
# start Node.js server with Grunt
#
ENTRYPOINT ["grunt", "connect:livereload", "watch"]
