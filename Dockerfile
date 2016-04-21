# https://docs.docker.com/reference/builder/
# NOTE dockerignore is ignored https://github.com/docker/docker/issues/9455

FROM ensime/ci-server:v2.x
MAINTAINER Sam Halliday, sam.halliday@gmail.com

################################################
# ENSIME Ivy / Coursier Cache
RUN\
  cd /root &&\
  git clone https://github.com/ensime/ensime-server.git &&\
  cd ensime-server &&\
  for SCALA_VERSION in 2.10.6 2.11.8; do\
    git clean -xfd &&\
    sbt ++$SCALA_VERSION gen-ensime gen-ensime-project ;\
  done &&\
  rm -rf /root/ensime-server &&\
  rm -rf $HOME/.coursier/cache/v1/https/oss.sonatype.org
