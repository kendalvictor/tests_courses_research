FROM python:3.6-alpine
MAINTAINER v.villacorta.unmsm@gmail.com

# Dependencies
RUN pip install --upgrade awscli \
    && apk add --update nodejs nodejs-npm

# Chek versions
RUN python -V
RUN node --version
RUN aws --version
