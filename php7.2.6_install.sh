#!/bin/bash
BASEDIR=/opt/src  #下载的资源保存目录
SOFTDIR=/opt/webserver      #软件安装目录

if [ 'grep "www" /etc/passwd | wc -l' ]; then
echo "adding user www"
groupadd www
useradd -s /sbin/nologin -M -g www www
else
echo "www user exists"
fi

yum -y install libxml2 libxml2-devel
yum install -y gcc gcc-c++  zlib-devel
yum -y install openssl openssl-devel
yum -y install libcurl-devel libcurl
yum install -y ncurses  gcc-c++
yum -y install libjpeg-devel
yum  -y install libpng
yum -y install freetype freetype-devel
yum install libpng-devel -y

if [ ! -d $BASEDIR ];then
	mkdir -p $BASEDIR
fi

if [ ! -d $SOFTDIR ];then
	mkdir -p $SOFTDIR
fi

cd $BASEDIR

echo "----------------------------------start install php -----------------------------"

if [ ! -f php-7.2.9.tar.bz2 ] ;then
    wget http://cn2.php.net/distributions/php-7.2.9.tar.bz2
fi

tar -xf php-7.2.9.tar.bz2 
cd php-7.2.9

./configure --prefix=$SOFTDIR/php --exec-prefix=$SOFTDIR/php \
--sbindir=$SOFTDIR/php/sbin --includedir=$SOFTDIR/php/include \
--libdir=$SOFTDIR/php/lib/php --mandir=$SOFTDIR/php/php/man \
--with-config-file-path=$SOFTDIR/php/etc --with-mhash --with-openssl \
--with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-gd --with-iconv \
--with-zlib --enable-zip --enable-inline-optimization \
--disable-debug --disable-rpath --enable-shared --enable-xml --enable-bcmath \
--enable-shmop --enable-sysvsem --enable-mbregex --enable-mbstring --enable-pcntl \
--enable-sockets --with-xmlrpc --enable-soap --without-pear --with-gettext \
--enable-session --with-curl --with-jpeg-dir --with-freetype-dir \
--enable-opcache --enable-fpm --with-fpm-user=www \
--with-fpm-group=www --without-gdbm --enable-fast-install --disable-fileinfo

if [ $? -ne 0 ];then
echo "configure failed ,please check it out!"
exit 1
fi

echo "make php-7, please wait for 20 minutes"
make
if [ $? -ne 0 ];then
echo "make failed ,please check it out!"
exit 1
fi

make install

if [ $? -ne 0 ];then
echo "install failed ,please check it out!"
exit 1
fi

##########创建配置文件php.ini##############
if [ ! -f $SOFTDIR/etc/php.ini ];then
	cp $BASEDIR/php-7.2.9/php.ini-production $SOFTDIR/php/etc/php.ini
fi

#创建配置文件php-fpm.ini
cd $SOFTDIR/php/etc
if [ ! -f php-fpm.conf ];then
	cp php-fpm.conf.default php-fpm.conf
fi

#创建配置文件www.conf
cd php-fpm.d/
if [ ! -f www.conf ];then
	cp www.conf.default www.conf
fi

chmod +x $SOFTDIR/php/sbin/php-fpm
rm -rf /usr/bin/php-fpm

ln -s $SOFTDIR/sbin/php-fpm  /usr/bin

echo "------------------Success install php7.2.9--------------------"
