nexus.md
===
# Guide for npm
https://blog.theodo.com/2016/01/speed-up-npm-install-with-a-nexus-proxy-to-cache-packages/

# Some npm packages are not found 

https://github.com/npm/npm/issues/13541#issuecomment-260777973
```
AllowEncodedSlashes NoDecode 
AllowEncodedSlashes On
```

# Upgrade

Download
Unpack tar inside /opt

https://support.sonatype.com/hc/en-us/articles/115000350007?_ga=2.88986463.533482664.1582329414-122856779.1579959708

Make sure to start and stop as nexus user
copy nexus.vmoptions to new bin folder
update nexus-latest

# Backup and Restore

https://help.sonatype.com/repomanager3/backup-and-restore?_ga=2.60243945.533482664.1582329414-122856779.1579959708

# Docker Repo cleanup
https://help.sonatype.com/repomanager3/repository-management/cleanup-policies#CleanupPolicies-DockerCleanupStrategies