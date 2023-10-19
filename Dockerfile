FROM centos:7 AS updated
RUN yum update -y && yum clean all && rm -rf /var/cache/yum

FROM updated AS pyenv
# hadolint ignore=DL3033
RUN yum install -y git \
        epel-release \
        # from pyenv wiki
        gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
        openssl-devel tk-devel libffi-devel xz-devel \
    && yum swap -y openssl-devel openssl11-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

# install pyenv for root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=SC2016
RUN curl https://pyenv.run | bash \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc

FROM pyenv as python311
RUN . ~/.bashrc \
    && CPPFLAGS="$(pkg-config --cflags openssl11)" \
        LDFLAGS="$(pkg-config --libs openssl11)" \
        pyenv install 3.11 \
        pyenv global "$(pyenv latest 3.11)"
