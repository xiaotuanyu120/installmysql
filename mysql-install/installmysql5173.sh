#!/bin/bash
set -e

## env setting
BASEDIR=/usr/local/mysql
DATADIR=/data/mysql
PASSWORD=adminmysql
PIDFILE=/usr/local/mysql/mysql.pid

## mysql base env install
yum install gcc gcc-c++ cmake ncurses-devel -y
yum groupinstall base "Development Tools" -y

## create user
groupadd mysql
useradd -r -g mysql mysql

## source package unzip
[[ -d mysql ]] || mkdir mysql && rm -rf mysql && mkdir mysql
tar zxvf mysql-5.1.72.tar.gz -C mysql
mv ./mysql/mysql-5.1.72/* ./mysql/
cd mysql

## mysql install
./configure --prefix=$BASEDIR --datadir=$DATADIR --with-mysqld-user=mysql --with-charset=utf8 --with-extra-charsets=all
make
make install

mkdir -p $DATADIR
chown -R mysql:mysql $BASEDIR
chown -R mysql:mysql $DATADIR

## mysql initial
./scripts/mysql_install_db --datadir=$DATADIR --user=mysql
cp ./support-files/mysql.server /etc/init.d/mysqld
rm -f /etc/my.cnf
cp support-files/my-large.cnf /etc/my.cnf
chmod 755 /etc/init.d/mysqld

sed -inr "s#^basedir=#basedir=$BASEDIR#g" /etc/init.d/mysqld
sed -inr "s#^datadir=#datadir=$DATADIR#g" /etc/init.d/mysqld
sed -inr "s#^pid_file=#pid_file=$PIDFILE#g" /etc/init.d/mysqld

sed -i "/\[mysqld\]/abasedir=$BASEDIR" /etc/my.cnf
sed -i "/\[mysqld\]/adatadir=$DATADIR" /etc/my.cnf
sed -i "/\[mysqld\]/apid_file=$PIDFILE" /etc/my.cnf

## service start and enanble
chkconfig mysqld on
/etc/init.d/mysqld start
$BASEDIR/bin/mysqladmin -u root password "$PASSWORD"
