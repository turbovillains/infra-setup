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

# ssh-keyscan git.nrtn.dev github.com bitbucket.org | tee /home/${BUILDER_USER}/.ssh/known_hosts
cat <<EOF | tee /home/${BUILDER_USER}/.ssh/known_hosts
github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
bitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQeJzhupRu0u0cdegZIa8e86EG2qOCsIsD1Xw0xSeiPDlCr7kq97NLmMbpKTX6Esc30NuoqEEHCuc7yWtwp8dI76EEEB1VqY9QJq6vk+aySyboD5QF61I/1WeTwu+deCbgKMGbUijeXhtfbxSxm6JwGrXrhBdofTsbKRUsrN1WoNgUa8uqN1Vx6WAJw1JHPhglEGGHea6QICwJOAr/6mrui/oB7pkaWKHj3z7d1IC4KWLtY47elvjbaTlkN04Kc/5LFEirorGYVbt15kAUlqGM65pk6ZBxtaO3+30LVlORZkxOh+LKL/BvbZ/iRNhItLqNyieoQj/uh/7Iv4uyH/cV/0b4WDSd3DptigWq84lJubb9t/DnZlrJazxyDCulTmKdOR7vs9gMTo+uoIrPSb8ScTtvw65+odKAlBj59dhnVp9zd7QUojOpXlL62Aw56U4oO+FALuevvMjiWeavKhJqlR7i5n9srYcrNV7ttmDw7kf/97P5zauIhxcjX+xHv4M=
bitbucket.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPIQmuzMBuKdWeF4+a2sjSSpBK0iqitSQ+5BM9KhpexuGt20JpTVM7u5BDZngncgrqDMbWdxMWWOGtZ9UgbqgZE=
bitbucket.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIazEu89wgQZ4bqs3d63QSMzYVa0MuJ2e2gKTKqu+UUO
git.nrtn.dev ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3fZy63PVgjZVntYpl61/GLtOaXF7quY2fCStMI2LzKsvWssr9Zi6Fk4o6Ei/ufV0rZEiuvZuf1dTBNjc4Dy4vw3YNfqcNXucVnTP/L8VRkiJKA4P79WTuymnzyeDMtgsgEHl7mxx36n45mXLae77/wG1U8gxCwHt3WghxS4N07C8j4cC2UEs/7EekcBj58EzAxRYpNocARREKABS9VIhVQgbV8wu3RPIgyhfOKWXneuiCE7tnRMXsPFInGWAe8GNQOh5V5SNz9KAPD27SwcZeQjon1cg2ZcrZt9Tz5LEt9wUCqdW0QVrg6tp0u9+BSTsN3FLUQDICyxOxoAZfzENBV2G/l94/z2H/Mn74ibkFMS2N+AmJNTg8AevF99GET0FJQQ0ox6oJwJ9A7RMKcMy8S/Q4qWEJhsDxcKvGihtwV5Y/wk/k+AluCfmIYVvi1yjjay+OluRVUS38yRuzEPxwX0/ruPCjPiksWXpjzQhHrdM8dAM7fH7AOu9aqjeEYJU=
git.nrtn.dev ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEOwh/c55x1wEVGCUitiPRNmyBCu79ZFbVmdD1Qu5WhkQQrRqOXqPxmMmC3UFxqHyNhGvPhgxzx/KfnFWITN+Q0=
git.nrtn.dev ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNjejhAYd8AujcrxsIWVb3aCHIFOulul4G7YplQ5OMZ
EOF
