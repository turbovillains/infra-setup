linux.md
====

# Disable sleep

https://askubuntu.com/questions/47311/how-do-i-disable-my-system-from-going-to-sleep

# Apt Proxy

```
Acquire {
  HTTP::proxy "http://proxy02.gda.allianz:3128";
  HTTPS::proxy "http://proxy02.gda.allianz:3128";
}
```