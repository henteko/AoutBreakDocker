FROM ubuntu
MAINTAINER henteko

RUN echo deb http://archive.ubuntu.com/ubuntu precise universe > /etc/apt/sources.list.d/universe.list
RUN apt-get update -qq
RUN apt-get install -qqy iptables ca-certificates lxc

# install redis
RUN apt-get install redis-doc
RUN apt-get install redis-server

# install nginx
RUN echo "deb http://nginx.org/packages/ubuntu/ precise nginx" >> /etc/apt/sources.list.d/nginx.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ precise nginx" >> /etc/apt/sources.list.d/nginx.list
curl http://nginx.org/keys/nginx_signing.key | sudo apt-key add -

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y make
RUN apt-get install -y dpkg-dev dh-make
RUN apt-get install -y libpcre3-dev libssl-dev zlib1g-dev libgeoip-dev libgd2-noxpm-dev libxml2-dev libxslt-dev libpam-dev libexpat-dev liblua5.1-dev libperl-dev

WORKDIR /usr/local/src/
RUN git clone https://github.com/simpl/ngx_devel_kit.git
RUN git clone https://github.com/chaoslawful/lua-nginx-module.git
RUN wget http://people.FreeBSD.org/~osa/ngx_http_redis-0.3.5.tar.gz
RUN tar xvfz ngx_http_redis-0.3.5.tar.gz

WORKDIR /ngxsrc
RUN apt-get source nginx-full
WORKDIR /ngxsrc/nginx-1.4.4
ADD nginx-1.4.4_debian_rules /ngxsrc/nginx-1.4.4/debian/rules
RUN dpkg-buildpackage -b
WORKDIR /ngxsrc
RUN dpkg -i nginx_1.4.4-1~precise_amd64.deb
ADD nginx.conf.sample /etc/nginx/nginx.conf

RUN apt-get install -y vim
RUN apt-get install -y curl

# ruby install 
WORKDIR /
RUN apt-get install -y ruby1.9.3
RUN gem install rubygems-update --no-ri --no-rdoc
RUN update_rubygems
RUN gem install bundler --no-ri --no-rdoc

# This will use the latest public release. To use your own, comment it out...
ADD https://get.docker.io/builds/Linux/x86_64/docker-latest /usr/local/bin/docker

# ...then uncomment the following line, and copy your docker binary to current dir.
#ADD ./docker /usr/local/bin/docker
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker
VOLUME /var/lib/docker
CMD wrapdocker
