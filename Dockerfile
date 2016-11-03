FROM ubuntu:16.04
MAINTAINER Adam Lukens<spawn968@gmail.com>

# Set up MakeMKV PPA
# https://launchpad.net/~heyarje/+archive/ubuntu/makemkv-beta
RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:heyarje/makemkv-beta
RUN apt-get update && apt-get install -y makemkv-bin makemkv-oss

RUN apt-get install -y makemkv-bin ruby handbrake-cli

WORKDIR /app
ADD makemkv_settings.conf /root/.MakeMKV/settings.conf
ADD Gemfile /app/
RUN gem install bundler
RUN bundle install
ADD . /app
VOLUME /mkv
VOLUME /videos
