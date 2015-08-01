# Webcam Auto-Brightness
### Auto-brightness for laptops using the webcam

This script grabs an image from the webcam, analyses the ambient luminosity and adjusts the screen brightness acording to it.

I don't guarantee that this is going to work for all of you. Actually it's not going to work for most of you without some changes in cfg.ini (the webcam dev file, the brightness file, the levels - which are different from one webcam to another)

I've tested the script only with my laptop ASUS X55SV and Ubuntu 10.04 Lucid.

The script shouldn't be too hard to use or understand as all the things you would have to change are placed in cfg.ini.

You'll have to install:
+ zenity (for informational dialogs)
+ streamer (for webcam image grab)
+ imagemagick (for image size reduction)
+ php5-cli and php5-gd (for image analysis)

Command for that:

    sudo apt-get install zenity streamer imagemagick php5-cli php5-gd

To kill the script either:  
CTRL + C if it runs from a terminal  
or  
rm /tmp/auto-brightness-*

I hope at least some of you manage to get it working :) The true thing is that it can't really be made generic as there are too many particular settings for each computer

You can donate through PayPal at [brucelee.duckdns.org/donation/Webcam-Auto-Brightness](http://brucelee.duckdns.org/donation/Webcam-Auto-Brightness)

    Since I can't directly add the PayPal donation button here, I've created a simple page
    which has the Donate button.
    
