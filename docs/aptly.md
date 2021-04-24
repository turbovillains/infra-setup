aptly.md
===

```
gpg --full-generate-key
```
Noroutine APT Repositories

Pay attention to gpg version
```
aptly publish update -gpg-key="Noroutine" -gpg-provider=gpg2 -architectures=all,amd64 buster filesystem:public:apps
aptly publish update -gpg-key="Noroutine" -gpg-provider=gpg2 -architectures=all,amd64 buster filesystem:public:bootstrap
```