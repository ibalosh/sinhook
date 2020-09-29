FROM ruby:2.5

ENV APP_PORT=8080
ENV APP_USERNAME=admin
ENV APP_PASSWORD=admin
ENV APP_BASIC_AUTH=true
ENV ENCRYPTED_YAML false
ENV RACK_ENV production

WORKDIR /usr/src/app

COPY . .
COPY config/general.yaml.default config/general.yaml
RUN gem install sinatra rerun && mkdir -p /usr/src/app
RUN mkdir hooks
RUN bundle install

VOLUME /usr/src/app/hooks

CMD rackup -p $APP_PORT
EXPOSE $APP_PORT
