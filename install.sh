#!/bin/bash
project_name=""
pwd=$(pwd)
apache="/etc/apache2/sites-available"
conf_file_if=""
echo_conf_file=1
gc="\033[1;32m"
inc="\033[7m"
bc="\033[1;34m"
lbc="\033[1;36m"
rc="\033[1;31m"
nc="\033[0m"
arr_uninstalled=()
arr_installed=()
arr_unchecked=()
arr_checked=()
main_pckgs='apache2 python3 virtualenv'
pckgs='neofetch net-tools wget htop tree vim mc git'


gc() {
	local func_result="$gc$@$nc"
  	echo "$func_result"
}


rc() {
	local func_result="$rc$@$nc"
  	echo "$func_result"
}


bc() {
	local func_result="$bc$@$nc"
  	echo "$func_result"
}


input() {
  read -p "$(echo -e "
  $@")" conf_file_if
}


exists_pckgs() {
	arr_uninstalled=()
	arr_installed=()
	arr_unchecked=()
	arr_checked=()

	for i in $main_pckgs
	do
	    if [ $(which $i) ]
		then
			arr_installed+="$i "
		else
			arr_checked+="$i "
		fi
	done

	if [ ! -f '/usr/lib/apache2/modules/mod_wsgi.so-3'* ]; then
	    arr_checked+="libapache2-mod-wsgi-py3 "
	else
		arr_instaled+="libapache2-mod-wsgi-py3 "
	fi
	
	for i in $pckgs
	do
		if [ "$i" == "net-tools" ]
		then
			i='ifconfig'
		fi
		if [ $(which $i) ]
		then
			if [ "$i" == "ifconfig" ]
			then
				i='net-tools'
			fi
			arr_installed+="$i "
		else
			arr_unchecked+="$i "
		fi
	done
}


print_installed_pckgs() {
	echo -e "\n  Установленные пакеты\n"
	for i in $arr_installed
	do
		echo -e "  [$(gc "instaled")]" $i
	done
}


print_ckecked_pckgs() {
	if [ "$arr_checked" != "" ]
	then
		echo -e "$nc  
  Пакеты для установки
		"
		for i in $arr_checked
		do
			echo -e "  [$gc X $nc]" $i
		done
		echo
	fi
}


print_uninstalled_pckgs() {
	if [ "$arr_unchecked" != "" ]
	then
		echo "
  Не установленные пакеты
	"
		for i in $arr_unchecked
		do

			echo '  [  ]' $i
		done
	fi
}


add_to_checked() {
	# if $arr_unchecked;
	# then
	input "Перечилсите через пробел пакеты, которые хотите установить или нажмите $gc'Enther'$nc для продолжения: $gc"
	# fi

	# if ! conf_file_if=""; 
	# then
		chck=' ' read -r -a array_chck <<< "$conf_file_if"
		for i in "${array_chck[@]}"
		do
		    arr_checked+="$i "
			TO_RM=$i
			TMP_LIST=""
			for VAR in $arr_unchecked
			do
			        if [ "$VAR" != "$TO_RM" ]
			        then
			                TMP_LIST="$TMP_LIST $VAR"
			        fi
			done
			arr_unchecked=$TMP_LIST
		done
	# fi
	echo -e $nc
	print_ckecked_pckgs
}


continue_to_insyall_pckgs() {
	if [ "$conf_file_if" != "" ]
	then
		input "Нажмите $gc'Enther'$nc для начала установки"
 		sudo apt install -y $conf_file_if
  	fi
}


replace_apache2_conf() {
	conf_file_if=""
	conf_file=$(sed -n '1p' < /etc/apache2/sites-available/000-default.conf)
	conf_file_cp=$(echo $conf_file | sed s/"#"//g)

	if [ "$conf_file" == "#$pwd/$project_name" ]
	then
		read -p "$(echo -e "
  $nc"Ранее Вы уже редактировали файл $(gc $apache/000-default.conf)" для проекта $(bc conf_file_cp)
  "нажмиите  $(gc "Enther")" для продожения: ")"
		echo_conf_file=0

	elif [ "$conf_file" == "<VirtualHost *:80>" ]
	then

		sudo mv $apache/000-default.conf $apache/000-default.conf.default
		sudo touch $apache/000-default.conf

	elif [ "$conf_file" != "#$pwd/"$project_name ] && [ "$conf_file" != "<VirtualHost *:80>" ]
	then
		while :
		do
			read -p "$(echo -e "
	Ранее Вы уже редактировали файл "$gc$apache/000-default.conf$nc" для проекта "$bc$conf_file_cp$nc"
	Что делать с файлом ?

	    "$gc"1)"$nc" Сделать backup и заменить
	    "$gc"2)"$nc" "$rc"Не"$nc" делать backup и заменить

	Сделайте выбор: $gc")" conf_file_if

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

	echo -e "$nc
	"

	if [ $echo_conf_file == 1 ]
	then
		echo "#$pwd/$project_name" | sudo tee -a $apache/000-default.conf
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
		echo "WSGIDaemonProcess "$project_name"_wsgi python-path=$pwd/$project_name python-home=$pwd/venv" | sudo tee -a $apache/000-default.conf
		echo "WSGIProcessGroup "$project_name"_wsgi" | sudo tee -a $apache/000-default.conf
		echo "WSGIScriptAlias / $pwd/$project_name/$project_name/wsgi.py" | sudo tee -a $apache/000-default.conf
		echo "</VirtualHost>" | sudo tee -a $apache/000-default.conf
	fi
}


update_system_pckgs() {
conf_file_if=""
input "Обновить пакеты Операционной системы?

  $(gc "1)") Да
  $(gc "2)") $(rc "Нет")

  Сделайте выбор: $gc"

	if [ "$conf_file_if" == "1" ]
	then
		sudo apt update
		sudo apt upgrade -y
	fi
	echo -e $nc
}


django_tool_bar() {
	add_string+="\n    'debug_toolbar',"
	add_string1+="\n    'debug_toolbar.middleware.DebugToolbarMiddleware',"
	add_string2+="\n    path('__debug__\/', include(debug_toolbar.urls)),"
	# ips=$(hostname -I)
	ips=""
	read -p "$(echo -e $nc"  укажите IP адресса для $gc"django-debug-toolbar"$nc: ")" ips
	for ip in ips
	do
		add_string3+="
    '"$ips"',"
		done
		echo "
# IPAddresses for django-debug-toolbar

INTERNAL_IPS = [
$add_string3
]
" | sudo tee -a $project_name/$project_name/settings.py

				echo "

if settings.DEBUG:
    import debug_toolbar

    urlpatterns = [
        path('__debug__/', include(debug_toolbar.urls)),
    ] + urlpatterns" | sudo tee -a $project_name/$project_name/urls.py

				sed -i "s/from django.urls import path/from django.urls import path, include/g" $project_name/$project_name/urls.py

}


crete_project() {
	mkdir $project_name
	cd $project_name
	pwd=$(pwd)

	virtualenv venv
	echo -e "$gc
	"
	source venv/bin/activate

	arr_checked=('django ')
	arr_unchecked=('django-debug-toolbar django-extensions djangorestframework pytelegrambotapi')
	print_ckecked_pckgs
	print_uninstalled_pckgs
	add_to_checked
	read -p "$(echo -e "
  Нажмите $gc'Enther'$nc для продолжения установки") " 
	pip install $arr_checked

	echo -e "$lbc
	"
	django-admin startproject $project_name
	sed -i "s/from pathlib import Path/import os\nfrom pathlib import Path/g" $project_name/$project_name/settings.py
	sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['\*']/g" $project_name/$project_name/settings.py

	add_string="    'django.contrib.staticfiles',"
	add_string1="    'django.middleware.clickjacking.XFrameOptionsMiddleware',"
	add_string2="    path('admin\/', admin.site.urls),"
	add_string3="	'127.0.0.1',"
	for i in $conf_file_if 
	do
		if [ "$i" != "pytelegrambotapi" ]
		then
			if [ "$i" == "djangorestframework" ]
			then
				add_string+="\n    'rest_framework',"
			elif [ "$i" == "django-debug-toolbar" ]
			then
				django_tool_bar
			elif [ "$i" == "django-extensions" ]
			then
				add_string+="\n    'django_extensions',"
			else
				add_string+="\n    '$i',"
			fi
		fi
	done

	sed -i "s/    'django.contrib.staticfiles',/$add_string/g" $project_name/$project_name/settings.py
	sed -i "s/    'django.middleware.clickjacking.XFrameOptionsMiddleware',/$add_string1/g" $project_name/$project_name/settings.py
	sed -i "s/from django.contrib import admin/from django.conf import settings\nfrom django.contrib import admin/g" $project_name/$project_name/urls.py
	# sed -i "s/    path('admin\/', admin.site.urls),/$add_string2/g" $project_name/$project_name/urls.py
	sed -i "s/        'DIRS': \[\],/        'DIRS': \[os.path.join(BASE_DIR, 'templates')\],/g" $project_name/$project_name/settings.py
	sed -i "s/LANGUAGE_CODE = 'en-us'/LANGUAGE_CODE = 'ru-ru'/g" $project_name/$project_name/settings.py
	sed -i "s/TIME_ZONE = 'UTC'/TIME_ZONE = 'Europe\/Moscow'/g" $project_name/$project_name/settings.py
	echo "STATIC_ROOT = os.path.join(BASE_DIR, 'static/')" | sudo tee -a $project_name/$project_name/settings.py
	echo "" | sudo tee -a $project_name/$project_name/settings.py
	echo "MEDIA_URL = '/media/'" | sudo tee -a $project_name/$project_name/settings.py
	echo "MEDIA_ROOT = os.path.join(BASE_DIR, 'media/')" | sudo tee -a $project_name/$project_name/settings.py

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

	cd $project_name
	echo -e "
	$nc"
	./manage.py migrate
	./manage.py createsuperuser
	./manage.py collectstatic
	echo -e "
	$lbc"	

	touch .gitignore
	echo "/static/" | sudo tee -a .gitignore
	echo "/logs/" | sudo tee -a .gitignore
	echo "db.sqlite3" | sudo tee -a .gitignore
	git init
	# git commit -m "init"
}


edit_chmod() {
	echo -e "$nc"
	chmod -R 777 $pwd	
}


main() {
	read -p "$(echo -e "\n  Имя проекта: $bc")" project_name
	echo -e "$nc"
	while [ -d $pwd/$project_name ]
	do
	read -p "$(echo -e "Директория $bc$pwd/$project_name$nc уже существует, выберите другое имя проекта: $bc")" project_name
	done

	update_system_pckgs
	exists_pckgs
	print_installed_pckgs
	print_uninstalled_pckgs
	print_ckecked_pckgs
	add_to_checked
	continue_to_insyall_pckgs
	crete_project
	replace_apache2_conf
	edit_chmod
	sudo service apache2 restart	
}
