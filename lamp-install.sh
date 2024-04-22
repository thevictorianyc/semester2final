#!/bin/bash

#update installation packages
sudo apt update -y

#LAMP install
sudo apt-get install -y apache2 mysql-server mysql-client php8.2 libapache2-mod-php git

#add the php ondrej repository
sudo add-apt-repository ppa:ondrej/php --yes

#install php dependencies required for laravel
sudo apt update -y
sudo apt install php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y

##remove php7.4
sudo apt-get purge -y php7.4 php7.4-common -y

#enable rewrite
sudo a2enmod rewrite

#restart apache
sudo systemctl restart apache2

#change directory in the bin directory
cd /usr/bin
install composer globally -y
sudo curl -sS https://getcomposer.org/installer | sudo php -q

#move content of default composer.phar
sudo mv composer.phar composer

#change directory in /var/www directory to clone laravel repo
cd /var/www/
sudo git clone https://github.com/laravel/laravel.git

#grant user permissions
sudo chown -R $USER:$USER /var/www/laravel
cd laravel/
install composer autoloader
composer install --optimize-autoloader --no-dev -no-interaction
composer update --no-interaction

#copy the content of default env file to .env 
sudo cp .env.example .env
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache
cd
cd /etc/apache2/sites-available/
sudo touch laravel_project.conf
sudo echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/laravel_project.conf

#enable laravel
sudo a2ensite laravel_project.conf

#disable default
sudo a2dissite 000-default.conf

#restart apache
sudo systemctl restart apache2

cd

#start mysql
sudo systemctl start mysql

#database creation and access
sudo mysql -uroot -e "CREATE DATABASE victoriao_db;"
sudo mysql -uroot -e "CREATE USER 'victoriao'@'localhost' IDENTIFIED BY 'bigwoo';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON victoriao_db.* TO 'victoriao'@'localhost';"

#navigate to home dir
cd /var/www/laravel

#edit .env file
sudo sed -i "23 s/^#//g" /var/www/laravel/.env
sudo sed -i "24 s/^#//g" /var/www/laravel/.env
sudo sed -i "25 s/^#//g" /var/www/laravel/.env
sudo sed -i "26 s/^#//g" /var/www/laravel/.env
sudo sed -i "27 s/^#//g" /var/www/laravel/.env
sudo sed -i '22 s/=sqlite/=mysql/' /var/www/laravel/.env
sudo sed -i '23 s/=127.0.0.1/=localhost/' /var/www/laravel/.env
sudo sed -i '24 s/=3306/=3306/' /var/www/laravel/.env
sudo sed -i '25 s/=laravel/=victoriao_db/' /var/www/laravel/.env
sudo sed -i '26 s/=root/=victoriao/' /var/www/laravel/.env
sudo sed -i '27 s/=/=bigwoo/' /var/www/laravel/.env

#generate php artisan key
sudo php artisan key:generate
sudo php artisan storage:link

#migration
sudo php artisan migrate
sudo php artisan db:seed

#restart apache2
sudo systemctl restart apache2

echo "end"
