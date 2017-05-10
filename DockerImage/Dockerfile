FROM suchja/wine
MAINTAINER Henryk Blasinski <hblasins@stanford.edu>

USER root

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y python-pip
RUN pip install awscli

RUN apt-get update \
	&& apt-get install -y exiftool \
	&& apt-get install -y imagemagick

COPY image-preprocess-aws.sh /image-preprocess-aws.sh
COPY AdobeDNGConverter.exe /AdobeDNGConverter.exe
COPY wine /root/.wine/

RUN chown root /home/xclient

WORKDIR /