# https://docs.docker.com/reference/builder/
# NOTE dockerignore is ignored https://github.com/docker/docker/issues/9455

FROM debian:jessie

MAINTAINER Viktor Hedefalk <hedefalk@gmail.com
ENV JAVA_VARIANT java-1.7.0-openjdk-amd64

ENV JAVA_HOME /usr/lib/jvm/${JAVA_VARIANT}/jre/
ENV JDK_HOME /usr/lib/jvm/${JAVA_VARIANT}/
ENV SCALA_VERSIONS 2.10.6 2.11.8


################################################
# Package Management
RUN\
  cat /etc/apt/sources.list | sed 's/^deb /deb-src /' >> /etc/apt/sources.list &&\
  echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf &&\
  echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf &&\
  apt-get update -qq &&\
  apt-get autoremove -qq &&\
  apt-get clean

################################################
# Base System
RUN\
  apt-get install -y host jq curl unzip git locales ca-certificates &&\
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&\
  locale-gen &&\
  apt-get clean

################################################
# Java
RUN\
  apt-get install -y openjdk-7-source &&\
  update-java-alternatives -s ${JAVA_VARIANT} &&\
  apt-get clean


################################################
# Fill up coursier cache  
RUN\
  curl -L -o coursier https://git.io/vgvpD && chmod +x coursier
  
RUN\
  for SCALA_VERSION in $SCALA_VERSIONS ; do\
    SCALA_EDITION=$(echo $SCALA_VERSION | cut -c1-4) &&\
    echo $SCALA_EDITION &&\
    ./coursier fetch\
    -r file:///$HOME/.m2/repository\
    -r https://oss.sonatype.org/content/repositories/snapshots\
    -r https://jcenter.bintray.com/\
    org.ensime:ensime_${SCALA_EDITION}:0.9.10-SNAPSHOT\
    -V org.scala-lang:scala-compiler:${SCALA_VERSION}\
    -V org.scala-lang:scala-library:${SCALA_VERSION}\
    -V org.scala-lang:scala-reflect:${SCALA_VERSION}\
    -V org.scala-lang:scalap:${SCALA_VERSION} ;\
  done ;
  
