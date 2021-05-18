#!/usr/bin/env bash -eux

apt-get -yyq install noroutine-jdk8 noroutine-maven noroutine-scala

mkdir -p /root/.m2 /home/${BUILDER_USER}/.m2
mkdir -p /root/.ivy2 /home/${BUILDER_USER}/.ivy2

cat <<EOF | tee /root/.m2/settings.xml | tee /home/${BUILDER_USER}/.m2/settings.xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                    http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <localRepository>/ci/.m2/repository</localRepository>
</settings>
EOF

# http://ant.apache.org/ivy/history/latest-milestone/settings/caches.html
cat <<EOF | tee /root/.ivy2/ivysettings.xml | tee /home/${BUILDER_USER}/.ivy2/ivysettings.xml
<ivysettings>
    <caches defaultCacheDir="/ci/.ivy2-cache"/>
</ivysettings>
EOF