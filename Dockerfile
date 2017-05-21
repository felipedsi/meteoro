FROM ruby:2.2.6

RUN apt-get update && \
    apt-get install -y libicu-dev

ENV LANG C.UTF-8

ENV GEM_HOME=/usr/src/app/.gems
ENV GEM_PATH=/usr/src/app/.gems

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

RUN gem install bundler

CMD ["./script/start"]

