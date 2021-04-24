gitlab.md
===

# SMTP

Examples: https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/smtp.md#smtp-without-ssl
no auth: https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/2427#note_285880224

Testing: https://docs.gitlab.com/omnibus/settings/smtp.html#testing-the-smtp-configuration
```
gitlab-rails console
Notify.test_email('oleksiy@noroutine.me', 'Message Subject', 'Message Body').deliver_now
```


# Update gitlab gpg keys

```
ansible -b bo01_git -m shell -a 'curl -L https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey | sudo apt-key add -'
```

# Update 

https://docs.gitlab.com/omnibus/update/

# Backup and Restore

Backup for restoration should be owned by git user
https://docs.gitlab.com/ee/raketasks/backup_restore.html#restore-for-omnibus-gitlab-installations

## Configuration
/etc/gitlab/
/etc/gitlab/ssl/
/etc/gitlab/ssl/gitlab.key
/etc/gitlab/ssl/gitlab.crt
/etc/gitlab/gitlab-secrets.json
/etc/gitlab/trusted-certs/
/etc/gitlab/gitlab.rb

## Check

gitlab-rake gitlab:check SANITIZE=true