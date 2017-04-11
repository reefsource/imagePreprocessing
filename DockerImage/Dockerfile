FROM suchja/wine
MAINTAINER Henryk Blasinski <hblasins@stanford.edu>

USER root
ENV DISPLAY :0

RUN apt-get update \
	&& apt-get install -y imagemagick \
	&& apt-get install -y exiftool

WORKDIR /