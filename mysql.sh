#!/bin/bash
BASEDIR=/opt/src 
SOFTDIR=/opt/webserver
MYSQL_DATA_PAHT=/home/data/mysql 
#判断安装目录是否存在

cd $BASEDIR

if [  -f mysql-5.7.20-linux-glibc2.12-x86_64.tar ];then
    tar zxf mysql-5.7.20-linux-glibc2.12-x86_64.tar
    tar -xf mysql-5.7.20-linux-glibc2.12-x86_64.tar.gz
    if [ -d $SOFTDIR/mysql ];then
        rm -rf $SOFTDIR/mysql
    fi
    mv mysql-5.7.20-linux-glibc2.12-x86_64 $SOFTDIR/mysql/
   
else
     wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.23-linux-glibc2.12-x86_64.tar
    if [ ! $? -ne 0 ];then
        echo "Downloads mysql failed, please check out ..."
        exit
    fi   
fi

if [ 'grep "mysql" /etc/passwd | wc -l' ]; then
echo "adding user mysql"
groupadd -r mysql
useradd -r -s /sbin/nologin -M -g mysql mysql
else
echo "mysql user exists"
fi


mkdir $SOFTDIR/mysql/data
chown -R mysql:mysql $SOFTDIR/mysql/data
chmod  755 $SOFTDIR/mysql/data
echo "export PATH=$PATH:$SOFTDIR/mysql/bin" >> /etc/profile
. /etc/profile
cat << EOF > /etc/my.cnf
[client]
socket=$SOFTDIR/mysql/mysql.sock
[mysqld]
basedir=$SOFTDIR/mysql/
datadir=$MYSQL_DATA_PAHT
socket=$SOFTDIR/mysql/mysql.sock
pid-file=$SOFTDIR/mysql/data/mysqld.pid
log-error=$SOFTDIR/mysql/mysql.err
log-bin=mysql-bin
server-id=1
EOF
cp $SOFTDIR/mysql/support-files/mysql.server /etc/init.d/mysqld
mysqld --initialize --user=mysql --basedir=$SOFTDIR/mysql/ --datadir=$MYSQL_DATA_PAHT
#查看默认mysql登陆密码
mysqlpd=`grep password /usr/local/mysql/mysql.err |awk -F "root@localhost: " '{print $2}'`

mysql -uroot -p$mysqlpd  -e "alter user root@localhost identified by '123456'" --connect-expired-password

echo "yes mysql install 123456"
