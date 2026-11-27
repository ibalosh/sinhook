FROM ruby:3.3.14

ENV APP_PORT=8080

ENV APP_USERNAME=sinhook
ENV APP_PASSWORD=sinhook
ENV APP_BASIC_AUTH=true
ENV ENCRYPTED_YAML false

ENV HOOKS_TO_STORE=50
ENV HOOKS_STORAGE=redis
ENV HOOKS_REDIS_HOST=localhost
ENV HOOKS_FOLDER_STORAGE_PATH="/data/"
ENV RACK_ENV production

# remove ssh client since we don't need it
RUN apt-get purge openssh-client -y

WORKDIR /app

COPY ./ /app
RUN bundle install
RUN mkdir $HOOKS_FOLDER_STORAGE_PATH

ENTRYPOINT ["sh", "./scripts/launch" ]
EXPOSE $APP_PORT
