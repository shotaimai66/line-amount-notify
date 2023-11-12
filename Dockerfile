FROM amazonlinux:2
ENV WORKDIR=/opt/app
ENV NODE_VERSION=16.14.0
ENV RUBY_VERSION=3.2.0
ENV NPM_VERSION=8.13.0
ENV YARN_VERSION=1.21.1
ENV AWSCLI_VERSION=1.18.219

RUN yum -y update
RUN yum install -y wget tar xz git gcc-c++ make \
 libssl-dev zlib zlib1g-dev zlib-devel bzip2 bzip2-devel readline-devel \
 openssl-devel which libffi-devel libyaml-devel unzip

WORKDIR ${WORKDIR}

RUN set -x; git clone https://github.com/anyenv/anyenv ${HOME}/.anyenv \
    && echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bash_profile \
    && echo 'eval "$(anyenv init -)"' >> ~/.bash_profile

RUN ${HOME}/.anyenv/bin/anyenv install --force-init
SHELL ["/bin/bash", "-l", "-c"]
ENV PATH ${HOME}/.anyenv/bin:$PATH

RUN anyenv install nodenv && anyenv install rbenv

RUN nodenv install "${NODE_VERSION}" && nodenv local "${NODE_VERSION}"
RUN rbenv install "${RUBY_VERSION}" && rbenv local "${RUBY_VERSION}"
RUN set -ex; npm install -g "npm@${NPM_VERSION}" "yarn@${YARN_VERSION}"
RUN echo 'export LANG=C.UTF-8' >> ~/.bash_profile
RUN echo 'export LANGUAGE=en_US:' >> ~/.bash_profile
RUN echo 'export RUBYPATH="${WORKDIR}:$RUBYPATH"' >> ~/.bash_profile
RUN yarn global add serverless

# Install awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

EXPOSE 3000
