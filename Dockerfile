# https://docs.docker.com/reference/builder/
# NOTE dockerignore is ignored https://github.com/docker/docker/issues/9455

FROM ensime/ensime:v1.x
MAINTAINER Sam Halliday, sam.halliday@gmail.com

################################################
# Java
#
# Alternative Javas by inspired by https://github.com/dockerfile/java/
# RUN\
#   for V in 6 7 8 ; do\
#     echo oracle-java${V}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections ;\
#   done ;\
#   apt-get install -y openjdk-7-source\
#                      oracle-java6-installer\
#                      oracle-java7-installer\
#                      oracle-java7-unlimited-jce-policy\
#                      oracle-java8-installer\
#                      oracle-java8-unlimited-jce-policy ;\
#   apt-get clean

################################################
# ENSIME Ivy Cache
# (could do with using the right scala versions)
RUN\
  cd /root &&\
  git clone https://github.com/ensime/ensime-server.git &&\
  cd ensime-server &&\
  for SCALA_VERSION in 2.10.6 2.11.8; do\
    git clean -xfd &&\
    sbt gen-ensime gen-ensime-project ;\
  done &&\
  rm -rf /root/ensime-server

################################################
# Fill up coursier cache
RUN\
  curl -L -o coursier https://git.io/v2L2P && chmod +x coursier
  
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
    
