#!/usr/bin/env bash -eux

apt-get -yyq install noroutine-jdk8 noroutine-maven

mkdir -p /root/.m2 /home/builder/.m2

cat <<EOF | tee /root/.m2/settings.xml | tee /home/builder/.m2/settings.xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                    http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <localRepository>/ci/.m2/repository</localRepository>
</settings>
EOF
