UPDATE mysql.user SET Password=PASSWORD('weakPassword') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
CREATE DATABASE jumpserver DEFAULT CHARSET 'utf8';
GRANT ALL PRIVILEGES ON jumpserver.* to 'jumpserver'@'127.0.0.1' IDENTIFIED BY 'weakPassword';


