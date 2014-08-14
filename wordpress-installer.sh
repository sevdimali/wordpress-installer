#!/bin/bash
#Checking Requirements
command -v zenity;
if [ $? == "1" ]; then
	read -p "You need to install zenity. Do you want to install? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo apt-get install zenity;
	fi
fi
command -v lftp;
if [ $? == "1" ]; then
	read -p "You need to install lftp. Do you want to install? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo apt-get install lftp;
	fi
fi
command -v notify-send;
if [ $? == "1" ]; then
	read -p "You need to install libnotify-bin. Do you want to install? " -n 1 -r
	echo    # (optional) move to a new line
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		sudo apt-get install libnotify-bin;
	fi
fi


notify-send "Welcome to Wordpress Installation!"
#Gathering Informations
setup_inf=$(zenity \
	--forms --title="Wordpress Installation" \
	--text="Kurulum işlemine başlamak için aşağıdaki bilgileri girin." \
	--separator=":" \
	--add-entry="DB Name" \
	--add-entry="DB Username" \
	--add-entry="DB User Password" \
	--add-entry="Ftp Server" \
	--add-entry="Ftp Username" \
	--add-entry="Ftp User Password")
#If Cancel
if [ $? == "1" ]; then
	exit;
fi


#Database Informations
DBNAME=$(echo $setup_inf | cut -d':' -f1);
DBUSER=$(echo $setup_inf | cut -d':' -f2);
DBPASS=$(echo $setup_inf | cut -d':' -f3);
#FTP Informations
FTPHOST=$(echo $setup_inf | cut -d':' -f4);
FTPUSER=$(echo $setup_inf | cut -d':' -f5);         
FTPPASS=$(echo $setup_inf | cut -d':' -f6);
DOMAIN=$(echo $setup_inf | cut -d':' -f5 | cut -d'@' -f1); 


#Choosing Plugins
wp_eklentileri=$(zenity  \
	--width=1100 --height=400 --list --text "Choose the plugins for adding to wordpress!" \
	--checklist --column "Choose" --column "Plugins" --column "Description" --separator=":" \
	FALSE "All in one Seo Pack" "All in One SEO Pack is a WordPress SEO plugin to automatically optimize your WordPress blog for Search Engines such as Google."\
	FALSE "Google Xml Sitemap" "In its simplest terms, a XML Sitemap-usually called Sitemap, with a capital S-is a list of the pages on your website."\
	FALSE "Wp Optimize" "Simple but effective plugin allows you to extensively clean up your WordPress database and optimize it without doing manual queries."\
	FALSE "AG Custom Admin" "All-in-one tool for admin panel customization. Change almost everything: admin menu, dashboard, login page, admin bar etc."\
	FALSE "Ozh Admin Drop Down Menu" "All admin links available in a neat horizontal drop down menu. Saves lots of screen real estate!"\
	FALSE "Codestyling localization" "You can manage and edit all gettext translation files (*.po/*.mo) in WordPress Admin Center."\
	FALSE "Maintenance Mode" "Adds a splash page to your site that lets visitors know your site is down for maintenance. "\
	FALSE "Wp Google Fonts" "The WP Google Fonts plugin allows you to easily add fonts from the Google Font Directory to your WordPress theme."\
	FALSE "Page Links To" "Lets you make a WordPress page (or other content type) link to an external URL of your choosing, instead of its WordPress URL."\
	FALSE "Nextgen Gallery" "The most popular WordPress gallery plugin and one of the most popular plugins of all time with over 10 million downloads."\
	FALSE "Category and Page Icons" "Easy add icons to sidebar of categories and pages."
	)
e=1;
for (( i = 1; i < 12; i++ )); do
	wp_eklentileri[$i]=$(echo $wp_eklentileri | cut -d':' -f$i);
	if [ "${wp_eklentileri[$i]}" == "All in one Seo Pack" ]; then
		eklenti[$e]="all-in-one-seo-pack"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Google Xml Sitemap" ]; then
		eklenti[$e]="google-xml-sitemap"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Wp Optimize" ]; then
		eklenti[$e]="wp-optimize"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "AG Custom Admin" ]; then
		eklenti[$e]="ag-custom-admin"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Ozh Admin Drop Down Menu" ]; then
		eklenti[$e]="ozh-admin-drop-down-menu"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Codestyling localization" ]; then
		eklenti[$e]="codestyling-localization"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Maintenance Mode" ]; then
		eklenti[$e]="wp-maintenance-mode"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Wp Google Fonts" ]; then
		eklenti[$e]="wp-google-fonts"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Page Links To" ]; then
		eklenti[$e]="page-links-to"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Nextgen Galeri" ]; then
		eklenti[$e]="nextgen-gallery"; e=$((e+1));
	elif [ "${wp_eklentileri[$i]}" == "Category and Page Icons" ]; then
		eklenti[$e]="category-page-icons"; e=$((e+1));
	fi

	if [ "${wp_eklentileri[$i-1]}" == "${wp_eklentileri[$i]}" ]; then
        break
    fi
done
#If Cancel
if [ $? == "1" ]; then
	exit;
fi


notify-send "Downloading files!"
#Downloading Latest Wordpress Files
if [ ! -f ./latest.zip ]; then
wget https://wordpress.org/latest.zip;
fi
#Unzipping Wordpress Zip
unzip latest.zip;
rm latest.zip


#Changing Directory into Wordpress
cd wordpress
#Configuring wp-config file
sed "s/database_name_here/$DBNAME/g" wp-config-sample.php > wp-config-sample-1.php;
sed "s/username_here/$DBUSER/g" wp-config-sample-1.php > wp-config-sample-2.php;
sed "s/password_here/$DBPASS/g" wp-config-sample-2.php > wp-config.php;
rm wp-config-sample-1.php wp-config-sample-2.php


#Downloading Plugins
cd wp-content/plugins &&
for (( i = 1; i < $e; i++ )); do
	echo "i="$i;
	echo "e="$e;
	wget http://downloads.wordpress.org/plugin/${eklenti[$i]}.zip
done
if [ "ls | *.zip" ]; then
	unzip "*.zip";
	rm *.zip;
fi


#Uploading Files and Folders to Server
notify-send "Files are uploading to server!"
SOURCEFOLDER="../../../wordpress"
TARGETFOLDER="/"
lftp -u $FTPUSER,$FTPPASS $FTPHOST -e "mirror --verbose --only-newer --reverse $SOURCEFOLDER $TARGETFOLDER/; bye";


#Cleaning to Unnecessary Files
rm -rf ../../wordpress
notify-send "Wordpress installation finished!"
zenity --text="Do you want to open admin panel?" --question;
if [ "$?" == "0" ]; then sensible-browser http://www.$DOMAIN.com/wp-admin & ; fi
exit;

