ARG DOCKER_HUB
ARG INFRA_VERSION
ARG CLOUDIDE_BASE

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/${CLOUDIDE_BASE}

MAINTAINER Noroutine GmbH <info@noroutine.me>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y install ca-certificates build-essential curl git software-properties-common xz-utils

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
USER 0
RUN update-ca-certificates

# Node, yarn, Go, Java, C/C++, PHP && Python
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    add-apt-repository ppa:longsleep/golang-backports && \
    curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal main" > /etc/apt/sources.list.d/llvm.list && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && \
    apt-get install -y \
    clang-tools-13 \
    clangd-13 \
    clang-tidy-13 \
    golang-go \
    gradle \
    maven \
    nodejs \
    openjdk-8-jdk \
    php \
    php-cli \
    php-mbstring \
    python3-dev \
    python3-pip \
    ruby \
    sudo \
    ruby-dev \
    unzip \
    yarn \
    zlib1g-dev && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*


# C/C++ symlinks
RUN ln -s /usr/bin/clangd-11 /usr/bin/clangd && \
    ln -s /usr/bin/clang-tidy-11 /usr/bin/clang-tidy

# CMake
RUN curl -O "https://cmake.org/files/v3.17/cmake-3.17.0-Linux-x86_64.sh" && \
    chmod a+x cmake-3.17.0-Linux-x86_64.sh && \
    ./cmake-3.17.0-Linux-x86_64.sh --prefix=/usr/ --skip-license && \
    rm cmake-3.17.0-Linux-x86_64.sh

# Python 2-3 dependencies
RUN pip3 install --upgrade pip Pygments && \
    pip3 install jupyter jupyter-server-proxy jupyter-theia-proxy jupyterhub jupyterlab && \
    rm -fr /root/.cache/* && \
    ln -sf /usr/bin/python3 /usr/bin/python

# PHP dependencies
RUN curl -s -o composer-setup.php https://getcomposer.org/installer && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Ruby dependencies
RUN gem install solargraph

# Rust
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    USER=root

RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y && \
    rustup update && \
    rustup component add rls rust-src rust-analysis

# User account
RUN adduser --disabled-password --gecos '' theia

RUN chmod g+rw /home && \
    mkdir -p /usr/local/cargo && \
    mkdir -p /usr/local/go && \
    mkdir -p /usr/local/go-packages && \
    chown -R theia:theia /usr/local/cargo /usr/local/go /usr/local/go-packages /home/theia && \
    rm -fr /tmp/*

# Jupyterhub Notebook
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /sbin/tini

RUN chmod +x /sbin/tini

RUN jupyter serverextension enable --sys-prefix jupyter_server_proxy && \
    jupyter labextension install @jupyterlab/server-proxy

COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

RUN mkdir /home/jovyan && chown theia:theia /home/jovyan

#Theia
USER 1000

# Go tools
RUN export GO111MODULE=off && \
    go get github.com/acroca/go-symbols && \
    go get github.com/alecthomas/gometalinter && \
    go get github.com/cweill/gotests/... && \
    go get github.com/davidrjenni/reftools/cmd/fillstruct && \
    go get github.com/fatih/gomodifytags && \
    go get github.com/go-delve/delve/cmd/dlv && \
    go get github.com/godoctor/godoctor && \
    go get github.com/haya14busa/goplay/cmd/goplay && \
    go get github.com/josharian/impl && \
    go get github.com/mdempsky/gocode && \
    go get github.com/mgechev/revive && \
    go get github.com/ramya-rao-a/go-outline && \
    go get github.com/rogpeppe/godef && \
    go get github.com/sourcegraph/go-langserver && \
    go get github.com/sqs/goreturns && \
    go get github.com/stamblerre/gocode && \
    go get github.com/tylerb/gotype-live && \
    go get github.com/uudashr/gopkgs/cmd/gopkgs && \
    go get github.com/zmb3/gogetdoc && \
    go get golang.org/x/lint/golint && \
    go get golang.org/x/tools/cmd/goimports && \
    go get golang.org/x/tools/cmd/gorename && \
    go get golang.org/x/tools/cmd/guru && \
    go get golang.org/x/tools/gopls && \
    go get honnef.co/go/tools/... && \
    go get winterdrache.de/goformat/goformat && \
    rm -fr /home/theia/go/pkg /home/theia/go/src

# Python tools
RUN python3 -m pip install -U autopep8 flake8 pylint python-language-server --user

WORKDIR /home/theia

COPY settings.json .theia/

ADD .yarnrc ./

RUN curl -sLo package.json https://raw.githubusercontent.com/theia-ide/theia-apps/master/theia-full-docker/latest.package.json && \
    yarn --cache-folder ./ycache && rm -rf ./ycache && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build ;\
    yarn theia download:plugins && \
    rm -fr /home/theia/.cache/* && \
    ln -s /home/jovyan workspace

VOLUME /home/jovyan

EXPOSE 8888

ENV GRANT_SUDO=yes
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins

ENV PATH=$PATH:/home/theia/go/bin:/home/theia/node_modules/.bin

ENV LC_ALL=C.UTF-8

ENV LANG=C.UTF-8

ENTRYPOINT ["/sbin/tini", "-g", "--"]

CMD ["start-notebook.sh"]
