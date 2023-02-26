#!/usr/bin/env bash -eu

SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}

mkdir -p /root/.ssh /home/${BUILDER_USER}/.ssh
chmod 700 /root/.ssh /home/${BUILDER_USER}/.ssh

if [[ ! -z "${SSH_PRIVATE_KEY}" ]]; then
    set -eu
    # http://docs.gitlab.com/ce/ci/ssh_keys/README.html
    which ssh-agent || ( apt-get update -yyq && apt-get install openssh-client -yyq )
    eval $(ssh-agent -s)
    echo "${SSH_PRIVATE_KEY}" | tr -d '\r' | ssh-add - > /dev/null
    # echo "${SSH_PRIVATE_KEY}" | tee /root/.ssh/id_rsa | tee /home/${BUILDER_USER}/.ssh/id_rsa | tr -d '\r' | ssh-add - > /dev/null
    # chmod 600 /root/.ssh/id_rsa /home/${BUILDER_USER}/.ssh/id_rsa
fi

# ssh-keyscan ${GIT_SERVER_HOST} git.nrtn.dev github.com bitbucket.org | tee /root/.ssh/known_hosts | tee /home/${BUILDER_USER}/.ssh/known_hosts
cat <<EOF | tee /root/.ssh/known_hosts | tee /home/${BUILDER_USER}/.ssh/known_hosts
git.nrtn.dev ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuyR7E25rhx6OUClwtQ9vzvxcfFdGhizhpmvcYFLDLJGs16moTUIUG9c/A5yrsF7Z4s1LZOU6MNu52z68ssV/I8zLtQJIKBc5wKBMSwHLCiRdLKcv+436Qw1yiHmEr/axO096J0/JENT9o9vTlHmILyZkQMOEHjiZcfDdQg3q+KWNo+JPJJb1/9ZxYB842dcbt5VkWrsh7QoCrvsauDV7847KLlu7XAOB+D0B3woNbtopdGk6+YVoIrSfDHZrvyWiQH0bgpyxNjLReJv1puOnv6cQQ+VkZgll7nwfSQxSFO72dxyfbp7FkCP4n00qFVbT+InWXZehx1M9j40pxxWjH+5CHgpr2qqaVdSuma6Hq+h3+eoFWwak+vYOG1FVOYg6Z9vx8TRcNS53xyaSK3DmvcSTgeUm55ZEQrNBnM+0m7DzEfP3OSXBOXIFglmFbsCE+gBUQ/6PdiWttt5Y7QanPm3zCB9C5QdHhn2z1EHY4FbXlEqvvIdIuIrsOKvIB4YM=
git.nrtn.dev ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEZ2PnObvd+SN0pNDVtR0p5nrLpYqVzGEHbN5dlMShSW5jC6YV6Loe6gyEef9ZIWnTM8bTBTT7Lb+LcI5siLJns=
git.nrtn.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYenh0DMmhFqRe2BbDdXuFKvH/J9pKUoHh5pZC4TsFXgithub.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==
EOF
