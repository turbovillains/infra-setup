#!/usr/bin/env bash -eux

# echo kernel.unprivileged_userns_clone = 1 | sudo tee -a /etc/sysctl.d/containers.conf
# systemctl -p /etc/sysctl.d/containers.conf

# cat << EOK | apt-key add -
# -----BEGIN PGP PUBLIC KEY BLOCK-----
# Version: GnuPG v1.4.5 (GNU/Linux)

# mQENBFtkV0cBCADStSTCG5qgYtzmWfymHZqxxhfwfS6fdHJcbGUeXsI5dxjeCWhs
# XarZm6rWZOd5WfSmpXhbKOyM6Ll+6bpSl5ICHLa6fcpizYWEPa8fpg9EGl0cF12G
# GgVLnnOZ6NIbsoW0LHt2YN0jn8xKVwyPp7KLHB2paZh+KuURERG406GXY/DgCxUx
# Ffgdelym/gfmt3DSq6GAQRRGHyucMvPYm53r+jVcKsf2Bp6E1XAfqBrD5r0maaCU
# Wvd7bi0B2Q0hIX0rfDCBpl4rFqvyaMPgn+Bkl6IW37zCkWIXqf1E5eDm/XzP881s
# +yAvi+JfDwt7AE+Hd2dSf273o3WUdYJGRwyZABEBAAG0OGRldmVsOmt1YmljIE9C
# UyBQcm9qZWN0IDxkZXZlbDprdWJpY0BidWlsZC5vcGVuc3VzZS5vcmc+iQE+BBMB
# CAAoBQJfcJJOAhsDBQkIKusHBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRBN
# ZDkDdQYKpB0xCACmtCT6ruPiQa4l0DEptZ+u3NNbZfSVGH4fE4hyTjLbzrCxqcoh
# xJvDKxspuJ85wWFWMtl57+lFFE1KP0AX2XTT+/v2vN1PIfwgOSw3yp2sgWuIXFAi
# 89YSjSh8G0SGAH90A9YFMnTbllzGoGURjSX03iasW3A408ljbDehA6rpS3t3FD7P
# PnUF6204orYu00Qvc54an/xVJzxupb69MKW5EeK7x8MJnIToT8hIdOdGVD6axsis
# x+1U71oMK1gBke7p4QPUdhJFpSUd6kT8bcO+7rYouoljFNYkUfwnqtUn7525fkfg
# uDqqXvOJMpJ/sK1ajHOeehp5T4Q45L/qUCb3iEYEExECAAYFAltkV0cACgkQOzAR
# t2udZSOoswCdF44NTN09DwhPFbNYhEMb9juP5ykAn0bcELvuKmgDwEwZMrPQkG8t
# Pu9n
# =42uC
# -----END PGP PUBLIC KEY BLOCK-----
# EOK

# echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

# apt-get update -yyq
# apt-get install -yqq buildah runc
