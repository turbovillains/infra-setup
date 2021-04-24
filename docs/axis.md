axis
===

# Create overlay image from png

```
convert ~/Documents/horiz_nrtn_overlay_big.png  -type truecolor  bmp3:/Users/oleksii/Documents/horiz_nrtn_overlay_small.bmp
```

# Enable SSH

Follow the steps below to enable SSH in Axis camera/video encoders:
1. Assure that product is running firmware version 5.50.1 or later where applicable.
2. Access the ssh file by using this link: http://IP/admin-bin/editcgi.cgi?file=/etc/conf.d/ssh (where IP is the product's IP address)
3. Enable SSH by setting SSHD_ENABLED=“yes”
4. Save the ssh file.
5. Restart the camera/video encoder.

# RTSP Link

rtsp://cam01.noroutine.me:554/axis-media/media.amp