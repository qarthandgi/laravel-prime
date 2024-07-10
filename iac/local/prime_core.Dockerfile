FROM ubuntu:22.04 AS base

LABEL maintainer="Niles Brandon"

ARG HOST_USER_GID

ARG NODE_VERSION=20
ARG POSTGRES_VERSION=15

WORKDIR /var/www/html

# Why we should switch it back at the end of build: [https://docs.docker.com/engine/faq/#why-is-debian_frontendnoninteractive-discouraged-in-dockerfiles]
ENV DEBIAN_FRONTEND noninteractive

# `ln -snf` options explained: [https://unix.stackexchange.com/q/561135 | https://superuser.com/a/1061057]
# Understanding timezones: [https://www.freekb.net/Article?id=965]
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && mkdir -p /etc/apt/keyrings \
    && apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2 dnsutils librsvg2-bin fswatch \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.3-cli php8.3-dev \
        php8.3-pgsql php8.3-sqlite3 php8.3-gd \
        php8.3-curl \
        php8.3-imap php8.3-mysql php8.3-mbstring \
        php8.3-xml php8.3-zip php8.3-bcmath php8.3-soap \
        php8.3-intl php8.3-readline \
        php8.3-ldap \
        php8.3-msgpack php8.3-igbinary php8.3-redis php8.3-swoole \
        php8.3-memcached php8.3-pcov php8.3-imagick php8.3-xdebug \
    && curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g pnpm \
    && npm install -g bun \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /etc/apt/keyrings/yarn.gpg >/dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/keyrings/pgdg.gpg >/dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y yarn \
    && apt-get install -y mysql-client \
    && apt-get install -y postgresql-client-$POSTGRES_VERSION \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.3

RUN groupadd --force -g $HOST_USER_GID app
RUN useradd -ms /bin/bash --no-user-group -g $HOST_USER_GID -u 1000 app

RUN mkdir /.composer
RUN chmod -R ugo+rw /.composer

#COPY package*.json /var/www/html/
#RUN npm i

#ENV COMPOSER_ALLOW_SUPERUSER=1
#COPY composer.* /var/www/html/
#RUN composer update --no-scripts

RUN #mkdir /var/www/html/node_modules/.vite \
#    && chown -R app:app /var/www/html/node_modules/.vite


ENV DEBIAN_FRONTEND newt

ENV XDEBUG_CONFIG "client_host=host.docker.internal"
ENV XDEBUG_MODE=debug

FROM base AS app
COPY iac/local/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY iac/local/php.ini /etc/php/8.3/cli/conf.d/99-apprun.ini
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM base AS worker
ENV XDEBUG_SESSION=1
COPY iac/local/php-worker.ini /etc/php/8.3/cli/conf.d/99-apprun.ini
COPY iac/local/supervisord-worker.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
