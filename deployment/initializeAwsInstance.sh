#!/usr/bin/env bash

sudo add-apt-repository ppa:webupd8team/java

sudo apt-get -y update

sudo apt-get -y upgrade

sudo apt-get -y install nodejs nodejs-legacy npm ruby git git-core nginx oracle-java8-installer

sudo npm install -g bower coffee-script sass

sudo su -c "gem install sass"

popd ~

git clone -b HACKWEEKOCT2015 https://github.com/ciroque/ccr-admin.git

popd > /dev/null

pushd ccr-admin

bower install

popd > /dev/null

./compile.sh

sudo mkdir /var/www

pushd /var/www

sudo ln -s ~/ccr-admin/src/main ccr-admin

popd > /dev/null

cp nginx/ccr-admin.nginx.conf /etc/nginx/sites-available/

pushd /etc/nginx/sites-enabled/

sudo ln -s /etc/nginx/sites-available/ccr-admin.nginx.conf ccradmin.nginx.conf

popd > /dev/null

sudo /etc/init.d/nginx reload
