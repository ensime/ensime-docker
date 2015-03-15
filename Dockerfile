# https://docs.docker.com/reference/builder/

# jessie doesn't have jdk6
FROM debian:wheezy

MAINTAINER Sam Halliday, sam.halliday@gmail.com
ENV JAVA_VARIANT java-1.6.0-openjdk-amd64


# Add Ubuntu's Oracle JDK bundles
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN cat /etc/apt/sources.list | sed 's/^deb /deb-src /' >> /etc/apt/sources.list
RUN apt-get update -qq
RUN apt-get upgrade -qq

# Build Java
RUN apt-get install -y --no-install-recommends openjdk-6-source openjdk-7-source

# Test Javas --- inspired by https://github.com/dockerfile/java/
RUN for V in 6 7 8 ; do\
      echo oracle-java${V}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections ;\
    done
RUN apt-get install -y --no-install-recommends \
                        oracle-java6-installer \
                        oracle-java7-installer \
                        oracle-java7-unlimited-jce-policy \
                        oracle-java8-installer \
                        oracle-java8-unlimited-jce-policy

# ensure ENSIME's official JDK trumps
ENV JAVA_HOME /usr/lib/jvm/${JAVA_VARIANT}/jre/
ENV JDK_HOME /usr/lib/jvm/${JAVA_VARIANT}/
RUN update-java-alternatives -s ${JAVA_VARIANT}


# SBT (and by implication, Scala)
RUN apt-get install -qq --no-install-recommends curl
ADD https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt /usr/bin/sbt
RUN chmod a+x /usr/bin/sbt
ENV SBT_VARIANTS 0.13.6 0.13.7
ENV SCALA_VARIANTS 2.9.2 2.9.3 2.10.5 2.11.6
RUN mkdir /tmp/sbt && cd /tmp/sbt &&\
    mkdir -p project src/main/scala &&\
    touch src/main/scala/scratch.scala &&\
    for SBT_VERSION in $SBT_VARIANTS ; do\
      echo "sbt.version=$SBT_VERSION" > project/build.properties ;\
      for SCALA_VERSION in $SCALA_VARIANTS ; do\
        sbt ++$SCALA_VERSION clean updateClassifiers compile ;\
      done ;\
    done


# Emacs
RUN apt-get install -y --no-install-recommends xvfb \
                                               debfoster
                                               libfribidi0 libm17n-0 libotf0 librsvg2-2 \
                                               librsvg2-common m17n-contrib m17n-db
RUN debfoster -q
RUN apt-get build-dep -y emacs23

ADD http://ftp.gnu.org/gnu/emacs/emacs-24.1.tar.bz2 /tmp/emacs-24.1.tar.bz2
RUN cd /tmp && tar xf emacs-24.1.tar.bz2 && cd emacs-24.1 && ./configure --prefix=/usr/lib/emacs-24.1 && make && make install

ADD http://ftp.gnu.org/gnu/emacs/emacs-24.2.tar.xz /tmp/emacs-24.2.tar.xz
RUN cd /tmp && tar xf emacs-24.2.tar.xz && cd emacs-24.2 && ./configure --prefix=/usr/lib/emacs-24.2 && make && make install

ADD http://ftp.gnu.org/gnu/emacs/emacs-24.3.tar.xz /tmp/emacs-24.3.tar.xz
RUN cd /tmp && tar xf emacs-24.3.tar.xz && cd emacs-24.3 && ./configure --prefix=/usr/lib/emacs-24.3 && make && make install

ADD http://ftp.gnu.org/gnu/emacs/emacs-24.4.tar.xz /tmp/emacs-24.4.tar.xz
RUN cd /tmp && tar xf emacs-24.4.tar.xz && cd emacs-24.4 && ./configure --prefix=/usr/lib/emacs-24.4 && make && make install

# undo the emacs build-deps
RUN echo Y | debfoster -f

# Shippable container requirements
RUN apt-get install -y --no-install-recommends git git-man less libcurl3-gnutls libedit2 \
                                               liberror-perl ncurses-term openssh-blacklist \
                                               openssh-blacklist-extra openssh-client openssh-server \
                                               python-pkg-resources python-setuptools python2.6 \
                                               python2.6-minimal rsync
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen

# be nice, save some space
RUN rm -rf /var/lib/apt/lists/* && apt-get clean
