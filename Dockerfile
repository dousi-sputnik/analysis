# -*- mode: dockerfile -*-
FROM ruby:3.0.4-buster

WORKDIR /abc_analysis

RUN apt-get update                                                                                                                      \
  && apt-get install                                                                                                                    \
    openssl                                                                                                                             \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash -                                                                            \
  && wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -                                         \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list                                      \
  && wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb                                                                   \
  && DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.22-1_all.deb                                                           \
  && apt-get update                                                                                                                     \
  && apt-get remove -y                                                                                                                  \
    libmariadbclient18                                                                                                                  \
    libmariadbclient-dev-compat                                                                                                         \
    libmariadbclient-dev                                                                                                                \
  && apt-get install -y --allow-unauthenticated                                                                                         \
    default-libmysqlclient-dev                                                                                                          \
    default-mysql-client                                                                                                                \
    libxml2-dev                                                                                                                         \
    libxslt-dev                                                                                                                         \
    libc6-dev                                                                                                                           \
    nodejs                                                                                                                              \
    yarn                                                                                                                                \
    zip                                                                                                                                 \
  && gem install foreman                                                                                                                \
  && gem install bundler                                                                                                                \
  && apt-get clean
RUN bundle config set force_ruby_platform true
RUN bundle config set --global force_ruby_platform true

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
