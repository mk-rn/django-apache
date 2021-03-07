#!/bin/bash
project_name=""
pwd=$(pwd)
apache="/etc/apache2/sites-available"
read -p "Имя проета: " project_name



sudo apt update
sudo apt upgrade -y
#sudo apt install neofetch wget mc htop vim net-tools apache2 python3-pip libapache2-mod-wsgi-py3 -y
sudo apt install neofetch wget mc htop vim net-tools apache2 python3-pip libapache2-mod-wsgi-py3 python3-virtualenv -y
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


echo "{% extends 'base.html' %}" | sudo tee -a $pwd/$project_name/templates/base.html
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
echo "</html>" | sudo tee -a $pwd/$project_name/templates/index.html


#python3 virtualenv venv
virtualenv venv
source venv/bin/activate
pip install django pytelegrambotapi
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


./manage.py makemigrations
./manage.py migrate
./manage.py createsuperuser
./manage.py collectstatic


sudo mv $apache/000-default.conf $apache/000-default.conf.default
sudo touch $apache/000-default.conf

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


sudo chown www-data:www-data $pwd/$project_name
sudo chown www-data:www-data $pwd/$project_name/db.sqlite3
sudo service apache2 restart

