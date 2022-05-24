#!/usr/bin/env bash -eux

mkdir -p "${RUNNER_ASSETS_DIR}" \
  && cd "${RUNNER_ASSETS_DIR}" \
  && curl -L -o runner.tar.gz https://github.com/actions/runner/releases/download/v${ACTIONS_RUNNER_VERSION}/actions-runner-linux-${ARCH}-${ACTIONS_RUNNER_VERSION}.tar.gz \
  && tar xzf ./runner.tar.gz \
  && rm runner.tar.gz \
  && ./bin/installdependencies.sh \
  && mv ./externals ./externalstmp \
  && apt-get install -y libyaml-dev

mkdir -p ${RUNNER_TOOL_CACHE} \
    && chgrp docker ${RUNNER_TOOL_CACHE} \
    && chmod g+rwx ${RUNNER_TOOL_CACHE}

echo "ImageOS=${ImageOS}" >> /etc/environment

chown -R ${RUNNER_USER}.users ${RUNNER_ASSETS_DIR}
