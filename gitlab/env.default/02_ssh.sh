#!/usr/bin/env bash -eu

SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}

mkdir -p /home/${BUILDER_USER}/.ssh
chmod 700 /home/${BUILDER_USER}/.ssh

if [[ ! -z "${SSH_PRIVATE_KEY}" ]]; then
    set -eu
    # http://docs.gitlab.com/ce/ci/ssh_keys/README.html
    which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
    eval $(ssh-agent -s)
    echo "${SSH_PRIVATE_KEY}" | tee /home/${BUILDER_USER}/.ssh/id_rsa | tr -d '\r' | ssh-add - > /dev/null
    chmod 600 /home/${BUILDER_USER}/.ssh/id_rsa
fi

# ssh-keyscan ${GIT_SERVER_HOST} git.nrtn.dev github.com bitbucket.org | tee /home/${BUILDER_USER}/.ssh/known_hosts
cat <<EOF | tee /home/${BUILDER_USER}/.ssh/known_hosts
git.nrtn.dev ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkQYJILFc3nfi9N6qamSAZ3d6RzLJko5zK2BvFQeZ/33JA7BQqmMP/ZvcUwXhCGE4KLR6QLIEdpCBgaJw8X0PoB6F+/uNpu0MDZQseux6AqsqcWPUcUkTpTSFo+DL3W0gH1lyqkQ57iBaAVQJNfUFtn2tYZMBIzBsx+KY/L6Ed+MKflgBJxNBUiO7g6eGSmPxvfemjv+6vB45jOCWH6NP6PI/2v8g0P53Tig24Rdvt4uFRN76djkxdOQz0sBQNurDiBKdjMlAkUhS2ARUDuTBbixWTvOu6wengsvhHRM3L6+nAvlJ6CLt7cA00uvpaxoedXehgWF+TdsF7LZ8vzJwh
git.nrtn.dev ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKyL5B1mva3/bIbMP6FuAaNo6idKEjWudZGlp3SubbXDlXfKwoh2aY8qFXoB+2Z+ntTLI2YShbFtkbvXe1H5t2U=
git.nrtn.dev ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkQYJILFc3nfi9N6qamSAZ3d6RzLJko5zK2BvFQeZ/33JA7BQqmMP/ZvcUwXhCGE4KLR6QLIEdpCBgaJw8X0PoB6F+/uNpu0MDZQseux6AqsqcWPUcUkTpTSFo+DL3W0gH1lyqkQ57iBaAVQJNfUFtn2tYZMBIzBsx+KY/L6Ed+MKflgBJxNBUiO7g6eGSmPxvfemjv+6vB45jOCWH6NP6PI/2v8g0P53Tig24Rdvt4uFRN76djkxdOQz0sBQNurDiBKdjMlAkUhS2ARUDuTBbixWTvOu6wengsvhHRM3L6+nAvlJ6CLt7cA00uvpaxoedXehgWF+TdsF7LZ8vzJwh
git.nrtn.dev ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKyL5B1mva3/bIbMP6FuAaNo6idKEjWudZGlp3SubbXDlXfKwoh2aY8qFXoB+2Z+ntTLI2YShbFtkbvXe1H5t2U=
git.nrtn.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8hMgNu4LRr9uflKE5vRmSXCTyy16K25k6QUmMidu0q
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==
EOF
