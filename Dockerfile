# https://docs.docker.com/reference/builder/
# NOTE dockerignore is ignored https://github.com/docker/docker/issues/9455

FROM ensime/ci-server:v2.x
MAINTAINER Sam Halliday, sam.halliday@gmail.com

################################################
# ENSIME Ivy / Coursier Cache
RUN\
  cd /root &&\
  git clone --depth 1 --branch 1.0 https://github.com/ensime/ensime-server.git &&\
  cd ensime-server &&\
  for SCALA_VERSION in 2.10.6 2.11.8; do\
    sbt ++$SCALA_VERSION ensimeConfig ensimeConfigProject ;\
  done &&\
  cd /root &&\
  rm -rf /root/ensime-server &&\
  git clone --depth 1 --branch 2.0 https://github.com/ensime/ensime-server.git &&\
  cd ensime-server &&\
  for SCALA_VERSION in 2.10.6 2.11.8; do\
    sbt ++$SCALA_VERSION ensimeConfig ensimeConfigProject ;\
  done &&\
  cd /root &&\
  rm -rf /root/ensime-server &&\
  git clone --depth 1 --branch 2.0 https://github.com/ensime/ensime-sbt.git &&\
  cd ensime-sbt &&\
  sbt updateClassifiers &&\
  cd /root &&\
  rm -rf /root/ensime-sbt &&\
  rm -rf $HOME/.coursier/cache/v1/https/oss.sonatype.org

################################################
# Emacs build tool
RUN cask upgrade-cask

################################################
# drone 0.5 uses /drone not /root
RUN mkdir /drone &&\
    mv /root/.sbt /root/.ivy2 /drone/
