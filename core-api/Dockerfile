FROM ruby:2.7.4
ENV RUBYOPT -EUTF-8

LABEL Name=gokabot-core-api Version=1.0.0

RUN apt update 
RUN apt install -y mecab libmecab-dev mecab-ipadic mecab-ipadic-utf8

RUN gem install bundler -v 2.1.2
RUN bundle config set without development
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
