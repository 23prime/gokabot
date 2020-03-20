FROM ruby:2.6.3
ENV RUBYOPT -EUTF-8

LABEL Name=gokabot-line Version=1.0.0

RUN apt update && apt -y install mecab libmecab-dev mecab-ipadic
RUN gem install bundler -v 2.0.2

RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development
COPY . .
