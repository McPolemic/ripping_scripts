FROM ubuntu:18.04
MAINTAINER Adam Lukens<spawn968@gmail.com>

WORKDIR /app

# Set up MakeMKV PPA
# https://launchpad.net/~heyarje/+archive/ubuntu/makemkv-beta
RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:heyarje/makemkv-beta

# Add the setting file and then install MakeMKV. This allows us to update
# MakeMKV whenever we update the serial key
ADD makemkv_settings.conf /root/.MakeMKV/settings.conf
RUN apt-get update && apt-get install -y makemkv-bin makemkv-oss

RUN apt-get install -y makemkv-bin ruby ruby-dev build-essential handbrake-cli

ADD Gemfile /app/
RUN gem install bundler
RUN bundle install
ADD . /app
VOLUME /mkv
VOLUME /videos
CMD ./run.sh
