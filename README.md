Wordpress-installer
-----------------

This is a bash script for installing wordpress to your server<br />

Requirements
-----------------
Before using the script you need to have this programs.<br />
1. zenity (User interface and dialogs )<br />
2. lftp ( Ftp uploads )<br />
3. notify-send ( Notifications )<br />

Features
-----------------
<ul>
<li>Downloading latest Wordpress files</li>
<li>Editing wp-config file with your information(dbname, dbusername, dbpassword)</li>
<li>Downloading selected plugins from list</li>
<li>And uploading all files to your server(using a ftp client)</li>
</ul>

Usage
-----------------
It's so simple. Just start script and it will do all work for you.
For starting script<br />
```
$ cd wordpress-installer
$ chmod +x ./wordpress-installer.sh
$ ./wordpress-installer.sh
```

#####And finally your wordpress site is ready.


