FROM python:3.6-slim-stretch
MAINTAINER v.villacorta.unmsm@gmail.com

# Updagre
RUN apt update -y
RUN apt upgrade -y

# Node8 install
RUN apt install -y curl bash-completion
RUN curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install -y nodejs
RUN node -v
RUN npm -v

# Python dependencies/libraries
RUN apt install -y libbz2-dev python-dev python3-dev build-essential \
    libssl-dev libffi-dev libncurses5-dev libncursesw5-dev xz-utils  \
    libopenblas-dev python3-venv llvm wget libsqlite3-dev libreadline-dev zlib1g-dev \
    unzip
RUN pip install awscli==1.16.69
RUN pip install boto3==1.9.79
RUN pip install numpy==1.16.1
RUN pip install pandas==0.24.1
RUN pip install dask==0.17.5

RUN python -V
RUN aws --version