gdm.md
===

# Disable sleep on AC

```
sudo -u Debian-gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
```