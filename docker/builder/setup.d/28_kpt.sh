#!/usr/bin/env bash -eux

curl -sL -o /usr/local/bin/kpt https://github.com/GoogleContainerTools/kpt/releases/download/v0.39.1/kpt_linux_amd64
shasum -a 256 /usr/local/bin/kpt | grep 7c8a6b92abd979621f955572a5ee5ddbba8a383b290dab121866b402a670aabf
chmod +x /usr/local/bin/kpt