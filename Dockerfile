# https://docs.docker.com/reference/builder/
# NOTE dockerignore is ignored https://github.com/docker/docker/issues/9455

FROM ensime/ci-server:v1.x
MAINTAINER Sam Halliday, sam.halliday@gmail.com

################################################
# ENSIME Ivy / Coursier Cache
RUN\
  cd /root &&\
  git clone --depth 1 --branch 1.0 https://github.com/ensime/ensime-server.git &&\
  cd ensime-server &&\
  for SCALA_VERSION in 2.10.6 2.11.7 2.11.8; do\
    git clean -xfd &&\
    sbt ++$SCALA_VERSION ensimeConfig ensimeConfigProject ;\
  done &&\
  rm -rf /root/ensime-server &&\
  rm -rf $HOME/.coursier/cache/v1/https/oss.sonatype.org
