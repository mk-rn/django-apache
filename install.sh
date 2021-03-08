#!/bin/bash
project_name=""
pwd=$(pwd)
apache="/etc/apache2/sites-available"
conf_file=$(sed -n '1p' < /etc/apache2/sites-available/000-default.conf)
conf_file_if=""
conf_file_cp=$(echo $conf_file | sed s/"#"//g)
echo_conf_file=1
gc="\033[1;32m"
inc="\033[7m"
bc="\033[1;34m"
lbc="\033[1;36m"
rc="\033[1;31m"
nc="\033[0m"


read -p "$(echo -e "\nИмя проета: $bc")" project_name
echo -e "$nc"
while [ -d $pwd/$project_name ]
do
read -p "$(echo -e "Директория $bc$pwd/$project_name$nc уже существует, выберите другое имя проекта: $bc")" project_name
echo -e "$nc
"
done


if [ "$conf_file" == "#$project_name" ]
then
	read -p "$(echo -e "
Ранее Вы уже редактировали файл "$gc$apache/000-default.conf$nc" для проекта "$bc$conf_file_cp$nc"
"нажмиите $gc"Enther"$nc" для продожения: ")"
	echo_conf_file=0

elif [ "$conf_file" == "<VirtualHost *:80>" ]
then

	sudo mv $apache/000-default.conf $apache/000-default.conf.default
	sudo touch $apache/000-default.conf

elif [ "$conf_file" != "#"$project_name ] && [ "$conf_file" != "<VirtualHost *:80>" ]
then
	while :
	do
		read -p "$(echo -e "
Ранее Вы уже редактировали файл "$gc$apache/000-default.conf$nc" для проекта "$bc$conf_file_cp$nc"
Что делать с файлом ?

    "$gc"1)"$nc" Сделать backup и заменить
    "$gc"2)"$nc" "$rc"Не"$nc" делать backup и заменить

Сделайте выбор: $gc")" conf_file_if
echo "$nc
"
		if [ "$conf_file_if" == "1" ]
		then
			sudo cp $apache/000-default.conf $apache/000-default.conf.$conf_file_cp
			sudo rm -r $apache/000-default.conf
		elif [ "$conf_file_if" == "2" ]
		then
			sudo rm -r $apache/000-default.conf
		fi
		sudo touch $apache/000-default.conf
		break
	done
fi


sudo apt update
sudo apt upgrade -y
sudo apt install -y neofetch wget mc htop vim net-tools apache2 python3-pip libapache2-mod-wsgi-py3 python3-virtualenv
#pip3 install virtualenv

mkdir $project_name
cd $project_name
mkdir $pwd/$project_name/logs
mkdir $pwd/$project_name/templates
mkdir $pwd/$project_name/templates/main
mkdir $pwd/$project_name/static
mkdir $pwd/$project_name/static/css
mkdir $pwd/$project_name/static/js


touch $pwd/$project_name/templates/base.html
touch $pwd/$project_name/templates/index.html
touch $pwd/$project_name/static/css/style.css

echo -e "
$lbc{% extends 'base.html' %}" | sudo tee -a $pwd/$project_name/templates/base.html
echo "" | sudo tee -a $pwd/$project_name/templates/base.html
echo "{% block title %}" | sudo tee -a $pwd/$project_name/templates/base.html
echo "    Главная страница" | sudo tee -a $pwd/$project_name/templates/base.html
echo "{% endblock %}" | sudo tee -a $pwd/$project_name/templates/base.html
echo "" | sudo tee -a $pwd/$project_name/templates/base.html
echo "{% block body %}" | sudo tee -a $pwd/$project_name/templates/base.html
echo "    <h1>Главная страница</h1>" | sudo tee -a $pwd/$project_name/templates/base.html
echo "{% endblock %}" | sudo tee -a $pwd/$project_name/templates/base.html
echo "{% load static %}" | sudo tee -a $pwd/$project_name/templates/index.html
echo "<!DOCTYPE html>" | sudo tee -a $pwd/$project_name/templates/index.html
echo "<html lang=\"ru\">" | sudo tee -a $pwd/$project_name/templates/index.html
echo "<head>" | sudo tee -a $pwd/$project_name/templates/index.html
echo "	  <meta charset="UTF-8">" | sudo tee -a $pwd/$project_name/templates/index.html
echo "    <title>{% block title %}{% endblock %}</title>" | sudo tee -a $pwd/$project_name/templates/index.html
echo "    <link rel=\"stylesheet\" type=\"text/css\" href=\"{% static 'css/style.css' %}\">" | sudo tee -a $pwd/$project_name/templates/index.html
echo "</head>" | sudo tee -a $pwd/$project_name/templates/index.html
echo "<body>" | sudo tee -a $pwd/$project_name/templates/index.html
echo "	  {% block body %}" | sudo tee -a $pwd/$project_name/templates/index.html
echo "	  {% endblock %}" | sudo tee -a $pwd/$project_name/templates/index.html
echo "</body>" | sudo tee -a $pwd/$project_name/templates/index.html
echo -e "</html>$bc
" | sudo tee -a $pwd/$project_name/templates/index.html


##python3 virtualenv venv
virtualenv venv
echo -e "$gc
"
source venv/bin/activate
pip install django pytelegrambotapi
echo -e "$lbc
"
django-admin startproject $project_name
sed -i "s/from pathlib import Path/import os\nfrom pathlib import Path/g" $project_name/$project_name/settings.py
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['\*']/g" $project_name/$project_name/settings.py
sed -i "s/        'DIRS': \[\],/        'DIRS': \[os.path.join(BASE_DIR, 'templates')\],/g" $project_name/$project_name/settings.py
sed -i "s/LANGUAGE_CODE = 'en-us'/LANGUAGE_CODE = 'ru-ru'/g" $project_name/$project_name/settings.py
echo "STATIC_ROOT = os.path.join(BASE_DIR, 'static/')" | sudo tee -a $project_name/$project_name/settings.py
echo "" | sudo tee -a $project_name/$project_name/settings.py
echo "MEDIA_URL = '/media/'" | sudo tee -a $project_name/$project_name/settings.py
echo "MEDIA_ROOT = os.path.join(BASE_DIR, 'media/')" | sudo tee -a $project_name/$project_name/settings.py

mv $project_name/manage.py manage.py
mv $project_name/$project_name $project_name"_"
rm -r $project_name
mv $project_name"_" $project_name

echo -e "
$nc"
./manage.py makemigrations
./manage.py migrate
./manage.py createsuperuser
./manage.py collectstatic
echo -e "
$lbc"



if [ $echo_conf_file == 1 ]
then
	echo "#$project_name" | sudo tee -a $apache/000-default.conf
	echo "<virtualHost *:80>" | sudo tee -a $apache/000-default.conf
	echo "#ServerAdmin admin@$project_name.localhost" | sudo tee -a $apache/000-default.conf
	echo "#DocumentRoot $pwd/$project_name" | sudo tee -a $apache/000-default.conf
	echo "" | sudo tee -a $apache/000-default.conf
	echo "ServerName $project_name" | sudo tee -a $apache/000-default.conf
	echo "ServerAlias $project_name" | sudo tee -a $apache/000-default.conf
	echo "ErrorLog $pwd/$project_name/logs/error.log" | sudo tee -a $apache/000-default.conf
	echo "CustomLog $pwd/$project_name/logs/access.log combined" | sudo tee -a $apache/000-default.conf
	echo "" | sudo tee -a $apache/000-default.conf
	echo "Alias /static $pwd/$project_name/static" | sudo tee -a $apache/000-default.conf
	echo "<Directory $pwd/$project_name/static>" | sudo tee -a $apache/000-default.conf
	echo "Require all granted" | sudo tee -a $apache/000-default.conf
	echo "</Directory>" | sudo tee -a $apache/000-default.conf
	echo "" | sudo tee -a $apache/000-default.conf
	echo "Alias /media $pwd/$project_name/media" | sudo tee -a $apache/000-default.conf
	echo "<Directory $pwd/$project_name/media>" | sudo tee -a $apache/000-default.conf
	echo "Require all granted" | sudo tee -a $apache/000-default.conf
	echo "</Directory>" | sudo tee -a $apache/000-default.conf
	echo "" | sudo tee -a $apache/000-default.conf
	echo "<Directory $pwd/$project_name/$project_name>" | sudo tee -a $apache/000-default.conf
	echo "<Files wsgi.py>" | sudo tee -a $apache/000-default.conf
	echo "Require all granted" | sudo tee -a $apache/000-default.conf
	echo "</Files>" | sudo tee -a $apache/000-default.conf
	echo "</Directory>" | sudo tee -a $apache/000-default.conf
	echo "" | sudo tee -a $apache/000-default.conf
	echo "WSGIDaemonProcess "$project_name"_wsgi python-path=$pwd/$project_name python-home=$pwd/$project_name/venv" | sudo tee -a $apache/000-default.conf
	echo "WSGIProcessGroup "$project_name"_wsgi" | sudo tee -a $apache/000-default.conf
	echo "WSGIScriptAlias / $pwd/$project_name/$project_name/wsgi.py" | sudo tee -a $apache/000-default.conf
	echo "</VirtualHost>" | sudo tee -a $apache/000-default.conf
fi

echo -e "$nc"
sudo chown www-data:www-data $pwd/$project_name
sudo chown www-data:www-data $pwd/$project_name/db.sqlite3
sudo service apache2 restart
