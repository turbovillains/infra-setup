#!/usr/bin/env bash -eux

curl -sLo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 \
  && chmod +x /usr/local/bin/dumb-init

mkdir -p "${RUNNER_ASSETS_DIR}" \
  && cd "${RUNNER_ASSETS_DIR}" \
  && curl -L -o runner.tar.gz https://github.com/actions/runner/releases/download/v${ACTIONS_RUNNER_VERSION}/actions-runner-linux-${ARCH}-${ACTIONS_RUNNER_VERSION}.tar.gz \
  && tar xzf ./runner.tar.gz \
  && rm runner.tar.gz \
  && ./bin/installdependencies.sh \
  && mv ./externals ./externalstmp \
  && apt-get install -y libyaml-dev

echo AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache > .env \
  && mkdir /opt/hostedtoolcache \
  && chgrp docker /opt/hostedtoolcache \
  && chmod g+rwx /opt/hostedtoolcache

chown -R ${RUNNER_USER}.users ${RUNNER_ASSETS_DIR}
