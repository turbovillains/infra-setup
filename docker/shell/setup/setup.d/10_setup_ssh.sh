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

cat <<EOF | tee /root/.ssh/known_hosts | tee /home/${BUILDER_USER}/.ssh/known_hosts
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQeJzhupRu0u0cdegZIa8e86EG2qOCsIsD1Xw0xSeiPDlCr7kq97NLmMbpKTX6Esc30NuoqEEHCuc7yWtwp8dI76EEEB1VqY9QJq6vk+aySyboD5QF61I/1WeTwu+deCbgKMGbUijeXhtfbxSxm6JwGrXrhBdofTsbKRUsrN1WoNgUa8uqN1Vx6WAJw1JHPhglEGGHea6QICwJOAr/6mrui/oB7pkaWKHj3z7d1IC4KWLtY47elvjbaTlkN04Kc/5LFEirorGYVbt15kAUlqGM65pk6ZBxtaO3+30LVlORZkxOh+LKL/BvbZ/iRNhItLqNyieoQj/uh/7Iv4uyH/cV/0b4WDSd3DptigWq84lJubb9t/DnZlrJazxyDCulTmKdOR7vs9gMTo+uoIrPSb8ScTtvw65+odKAlBj59dhnVp9zd7QUojOpXlL62Aw56U4oO+FALuevvMjiWeavKhJqlR7i5n9srYcrNV7ttmDw7kf/97P5zauIhxcjX+xHv4M=
bitbucket.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPIQmuzMBuKdWeF4+a2sjSSpBK0iqitSQ+5BM9KhpexuGt20JpTVM7u5BDZngncgrqDMbWdxMWWOGtZ9UgbqgZE=
bitbucket.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIazEu89wgQZ4bqs3d63QSMzYVa0MuJ2e2gKTKqu+UUO
git.nrtn.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNmUvw88670X0n2MYXj8U2NJSp1wlYVk04oeoGy5w5x
git.nrtn.dev ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCobQZkY6bX72/ReU7R8QNR+xnuXBOPr02/83mnOb2OB30hGeHiHFblz7mtj8D4ibosvcf5IbHc2NwQ70OwskG/HeDQ4362F+Q9j9McWk7x+/+gW5zxVFmRMjtJE82XiBtDCAtJGAjT/3MyrNVkvcEgiPlyFrJkl6sj/Ff0B2rpyOSxiOSSYNOtjFjRg3iNZG28bnfIWZ6eehYKVDQOB9whL4UdkWmhG4gmpWZ/DED/2oyGLDSq0AXe1SzMOnFH+feWKk3PEXCqq23+TLLcpZJsew6t/trI5YmoePhTesYOvYK/HfVMowf13L90F/7D9vrDyZ/GQ2ARf4mNjQ67pOiN1gq+0ytaqbGhIHeTh230/EofDHNd69pG4Bj89JnAJK9hKSOtvJEMixXKM2U9SDzgSEY/4xDCNaWA7IGuV4ZdEf9JFVnIsqh/KHkVYei+Bz7YMP2IdB+N4MDULZuy0+694dj2gbre00CDzURdUMWuezkwjyl5Zba98EGoDeFXW3E=
git.nrtn.dev ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDGRB/XycoetxC9tzMw9+/9rjs9n6WGqYIwHqB6jmQTpXZUcRJnUS58rR/8wzVteCKNimM2AdvVC+M6n6VZZo38=
EOF
