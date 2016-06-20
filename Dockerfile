# https://docs.docker.com/reference/builder/
# NOTE dockerignore is ignored https://github.com/docker/docker/issues/9455

# jessie doesn't have jdk6
FROM debian:wheezy

MAINTAINER Sam Halliday, sam.halliday@gmail.com
ENV JAVA_VARIANT java-1.6.0-openjdk-amd64

ENV JAVA_HOME /usr/lib/jvm/${JAVA_VARIANT}/jre/
ENV JDK_HOME /usr/lib/jvm/${JAVA_VARIANT}/
ENV SBT_VARIANTS 0.13.9 0.13.11
ENV SCALA_VARIANTS 2.10.6 2.11.7 2.11.8

################################################
# Package Management
RUN\
  echo 'deb http://ftp.debian.org/debian wheezy-backports main' >> /etc/apt/sources.list &&\
  cat /etc/apt/sources.list | sed 's/^deb /deb-src /' >> /etc/apt/sources.list &&\
  echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf &&\
  echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf &&\
  apt-get update -qq &&\
  apt-get autoremove -qq &&\
  apt-get clean

################################################
# Base System
RUN\
  apt-get install -y curl host jq unzip git locales ca-certificates &&\
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&\
  locale-gen &&\
  apt-get clean

################################################
# Java
RUN\
  apt-get install -y openjdk-6-source &&\
  update-java-alternatives -s ${JAVA_VARIANT} &&\
  apt-get clean

################################################
# SBT (and by implication, Scala)
ADD https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt /usr/bin/sbt
RUN chmod a+x /usr/bin/sbt
RUN\
  mkdir /tmp/sbt &&\
  cd /tmp/sbt &&\
  mkdir -p project src/main/scala &&\
  touch src/main/scala/scratch.scala &&\
  for SBT_VERSION in $SBT_VARIANTS ; do\
    echo "sbt.version=$SBT_VERSION" > project/build.properties &&\
    for SCALA_VERSION in $SCALA_VARIANTS ; do\
      sbt ++$SCALA_VERSION clean updateClassifiers compile ;\
    done ;\
  done &&\
  rm -rf /tmp/sbt

################################################
# Emacs
#
# This involves installing the build-deps for emacs23. To clean up we
# need to take a debfoster snapshot of before and agressively purge
# once we have done the compiles. Having the additional system emacs
# ensures we have all runtime deps for our builds.
RUN\
  apt-get install -y emacs23 &&\
  apt-get clean
RUN\
  apt-get install -y debfoster &&\
  debfoster -q &&\
  apt-get build-dep -y emacs23 &&\
  mkdir /tmp/emacs-build &&\
  for EMACS_VERSION in 24.3 24.5 ; do\
    curl http://ftp.gnu.org/gnu/emacs/emacs-${EMACS_VERSION}.tar.xz -o /tmp/emacs-${EMACS_VERSION}.tar.xz &&\
    cd /tmp && tar xf emacs-${EMACS_VERSION}.tar.xz &&\
    cd emacs-${EMACS_VERSION} &&\
    ./configure --prefix=/opt/emacs-${EMACS_VERSION} &&\
    make && make install ;\
  done &&\
  echo Y | debfoster -f &&\
  rm -rf /tmp/emacs* &&\
  apt-get clean
ENV PATH /opt/emacs-24.5/bin:${PATH}

################################################
# Cask
RUN\
  apt-get install -y python &&\
  curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python &&\
  apt-get clean
ENV PATH /root/.cask/bin:${PATH}

################################################
# ensime-vim
RUN\
  apt-get install -yy make g++ gcc openssl libssl-dev ruby ruby-dev python-dev python-mock python-pip &&\
  pip install websocket-client &&\
  gem install bundle &&\
  apt-get clean

################################################
# Drone deployment support
RUN\
  apt-get install -yy openssh-client ccrypt &&\
  apt-get clean
