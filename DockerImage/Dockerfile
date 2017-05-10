FROM alpine
MAINTAINER Henryk Blasinski <hblasins@stanford.edu>

RUN apk update
RUN apk add bash
RUN apk add wine
RUN apk add exiftool
RUN apk add imagemagick

RUN apk --no-cache update && \
    apk --no-cache add python py-pip py-setuptools ca-certificates curl groff less && \
    pip --no-cache-dir install awscli && \
    rm -rf /var/cache/apk/*

COPY wine /root/.wine/
COPY AdobeDNGConverter.exe /AdobeDNGConverter.exe
COPY image-preprocess.sh image-preprocess.sh