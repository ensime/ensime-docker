# https://docs.docker.com/reference/builder/
# NOTE dockerignore is ignored https://github.com/docker/docker/issues/9455

# jessie doesn't have jdk6
FROM debian:wheezy

MAINTAINER Sam Halliday, sam.halliday@gmail.com
ENV JAVA_VARIANT java-1.6.0-openjdk-amd64

ENV JAVA_HOME /usr/lib/jvm/${JAVA_VARIANT}/jre/
ENV JDK_HOME /usr/lib/jvm/${JAVA_VARIANT}/
ENV SBT_VARIANTS 0.13.7-RC3 0.13.7 0.13.8
ENV SCALA_VARIANTS 2.9.2 2.9.3 2.10.5 2.11.7

################################################
# Package Management
RUN\
  echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main' >> /etc/apt/sources.list &&\
  echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main' >> /etc/apt/sources.list &&\
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 &&\
  cat /etc/apt/sources.list | sed 's/^deb /deb-src /' >> /etc/apt/sources.list &&\
  echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf &&\
  echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf &&\
  apt-get update -qq &&\
  apt-get autoremove -qq &&\
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
  apt-get install -qq curl &&\
  apt-get clean &&\
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
# ensures we have all runtime deps for our builds. Xvfb is needed to
# run headless tests.
RUN\
  apt-get install -y emacs23 &&\
  apt-get clean
RUN\
  apt-get install -y debfoster &&\
  debfoster -q &&\
  apt-get build-dep -y emacs23 &&\
  mkdir /tmp/emacs-build &&\
  curl http://ftp.gnu.org/gnu/emacs/emacs-24.1.tar.bz2 -o /tmp/emacs-24.1.tar.bz2 &&\
  cd /tmp && tar xf emacs-24.1.tar.bz2 && cd emacs-24.1 && ./configure --prefix=/opt/emacs-24.1 && make && make install &&\
  curl http://ftp.gnu.org/gnu/emacs/emacs-24.2.tar.xz -o /tmp/emacs-24.2.tar.xz &&\
  cd /tmp && tar xf emacs-24.2.tar.xz && cd emacs-24.2 && ./configure --prefix=/opt/emacs-24.2 && make && make install &&\
  curl http://ftp.gnu.org/gnu/emacs/emacs-24.3.tar.xz -o /tmp/emacs-24.3.tar.xz &&\
  cd /tmp && tar xf emacs-24.3.tar.xz && cd emacs-24.3 && ./configure --prefix=/opt/emacs-24.3 && make && make install &&\
  curl http://ftp.gnu.org/gnu/emacs/emacs-24.4.tar.xz -o /tmp/emacs-24.4.tar.xz &&\
  cd /tmp && tar xf emacs-24.4.tar.xz && cd emacs-24.4 && ./configure --prefix=/opt/emacs-24.4 && make && make install &&\
  curl http://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.xz -o /tmp/emacs-24.5.tar.xz &&\
  cd /tmp && tar xf emacs-24.5.tar.xz && cd emacs-24.5 && ./configure --prefix=/opt/emacs-24.5 && make && make install &&\
  echo Y | debfoster -f &&\
  rm -rf /tmp/emacs* &&\
  apt-get clean
