#!/bin/bash
#set -xv

notify-send "Wordpress Kurulumuna Hoşgeldiniz!"
#İŞLEMLER
islemler=$(zenity  --width=300 --height=300 --list --text "Yapmak istediğiniz işlemleri seçiniz!" --checklist --column "Seç" --column "İşlemler" --separator=":" \
	FALSE "Domain Satın Alma" \
	FALSE "Domain Ekleme" \
	FALSE "Veritabanı İşlemleri" \
	FALSE "FTP Accountları" \
	FALSE "Email Hesapları")

for (( i = 1; i < 6; i++ )); do
	islem[$i]=$(echo $islemler | cut -d':' -f$i);
	if [ "${islem[$i]}" == "Domain Satın Alma" ]; then
			google-chrome "http://www.isimtescil.net/domain/domain-kayit.aspx" > /dev/null;
	elif [ "${islem[$i]}" == "Domain Ekleme" ]; then
			google-chrome "https://tr1.hostgator.com.tr:2083/cpsess8165069196/frontend/x3/addon/index.html" > /dev/null;
	elif [ "${islem[$i]}" == "Veritabanı İşlemleri" ]; then
			google-chrome "https://tr1.hostgator.com.tr:2083/cpsess8165069196/frontend/x3/sql/index.html" > /dev/null;
	elif [ "${islem[$i]}" == "FTP Accountları" ]; then
			google-chrome "https://tr1.hostgator.com.tr:2083/cpsess8165069196/frontend/x3/ftp/accounts.html" > /dev/null ;
	elif [ "${islem[$i]}" == "Email Hesapları" ]; then
			google-chrome "https://tr1.hostgator.com.tr:2083/cpsess8165069196/frontend/x3/mail/pops.html" > /dev/null; 
	fi
done
zenity --text="Kuruluma devam etmek istiyor musunuz?" --question;
if [ "$?" == "1" ]; then exit; fi


#FORM İLE BİLGİLER ALINIYOR
setup_inf=$(zenity \
	--forms --title="Wordpress Kurulumu" \
	--text="Kurulum işlemine başlamak için aşağıdaki bilgileri girin." \
	--separator=":" \
	--add-entry="Veritabanı Adı" \
	--add-entry="Veritabanı Kullanıcı Adı" \
	--add-entry="Veritabanı Kullanıcı Şifresi" \
	--add-entry="Ftp Serveri" \
	--add-entry="Ftp Kullanıcı Adı" \
	--add-entry="Ftp Kullanıcı Şifresi ")
#VERİTABANI BİLGİLERİ
DBNAME=$(echo $setup_inf | cut -d':' -f1);
DBUSER=$(echo $setup_inf | cut -d':' -f2);
DBPASS=$(echo $setup_inf | cut -d':' -f3);
#FTP BİLGİLERİ
FTPHOST=$(echo $setup_inf | cut -d':' -f4);
FTPUSER=$(echo $setup_inf | cut -d':' -f5);         
FTPPASS=$(echo $setup_inf | cut -d':' -f6);
DOMAIN=$(echo $setup_inf | cut -d':' -f5 | cut -d'@' -f1); 


#YÜKLENECEK EKLENTİLERİN SEÇİLMESİ
wp_eklentileri=$(zenity  \
	--width=500 --height=400 --list --text "Wordpress'e eklemek istediğiniz eklentileri seçin!" \
	--checklist --column "Seç" --column "Eklentiler" --column "Açıklama" --separator=":" \
	FALSE "All in one Seo Pack" "Seo Eklentisi"\
	FALSE "Google Xml Sitemap" "Otomatik Sitemap Oluşturma"\
	FALSE "Wp Optimize" "Wordpress Optimize Eklentisi"\
	FALSE "AG Custom Admin" "Admin Girişi Özelleştirme"\
	FALSE "Ozh Admin Drop Down Menu" "Admin Paneli Özelleştirme"\
	FALSE "Codestyling localization" "Sitedeki Dil Özelleştirme"\
	FALSE "Maintenance Mode" "Bakım Modu"\
	FALSE "Wp Google Fonts" "Font Özelleştirme"\
	FALSE "Page Links To" "Sayfalara Özel Link Ekleme"\
	FALSE "Nextgen Galeri" "Galeri Eklentisi"\
	FALSE "Category and Page Icons" "Kategori ve Sayfa ikonları"
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
done


#dosya yoksa indir
notify-send "Kurulum işlemi başlıyor!"
#Türkçe son versiyon indiriliyor
VERSIYON=$(lynx --source http://tr.wordpress.org/releases/#latest | grep -m 1 "<td>" | cut -d'>' -f3 | cut -d'<' -f1);
wget http://tr.wordpress.org/wordpress-$VERSIYON-tr_TR.tar.gz;
#Arşivden çıkartılıyor
tar -zxvf wordpress-$VERSIYON-tr_TR.tar.gz;
#Wordpress klasörüne geçiliyor
cd wordpress
#Veritabanı bilgilieri dosyaya ekleniyor
sed "s/veritabaniismi/$DBNAME/g" wp-config-sample.php > wp-config-sample-1.php;
sed "s/kullaniciadi/$DBUSER/g" wp-config-sample-1.php > wp-config-sample-2.php;
sed "s/parola/$DBPASS/g" wp-config-sample-2.php > wp-config.php;
rm wp-config-sample-1.php wp-config-sample-2.php

#Gereksiz temalar siliniyor
cd wp-content/themes &&
rm -rf twentyten;
rm -rf twentyeleven;
rm -rf twentytwelve;

#Eklentiler klasöre ekleniyor
cd ../plugins &&
for (( i = 1; i < $e; i++ )); do
	wget http://downloads.wordpress.org/plugin/${eklenti[$i]}.zip
done
unzip "*.zip";
rm *.zip;
rm hello.php


#Bulunduğum dizinde ne var ne yoksa yükle
notify-send "Ftp'ye yükleme işlemi başladı!"
SOURCEFOLDER="/home/$USER/wordpress"
TARGETFOLDER="/"
lftp -f "
open $FTPHOST
user $FTPUSER $FTPPASS
lcd $SOURCEFOLDER
mirror --reverse --verbose $SOURCEFOLDER $TARGETFOLDER
bye
";


#Gereksiz dosya klasörler siliniyor
cd /home/$USER &&
rm -rf wordpres*
notify-send "Sitenin kurulumu tamamlandı!"
zenity --text="Admin Paneli Açılsın mı?" --question;
if [ "$?" == "0" ]; then google-chrome http://www.$DOMAIN.com/wp-admin; fi
exit;

