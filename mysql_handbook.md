### 创建用户

说明:username - 你将创建的用户名, host - 指定该用户在哪个主机上可以登陆,如果是本地用户可用localhost, 如果想让该用户可以从任意远程主机登陆,可以使用通配符%. password - 该用户的登陆密码,密码可以为空,如果为空则该用户可以不需要密码登陆服务器.

```mysql
CREATE USER 'username'@'host' IDENTIFIED BY 'password'; 

例如：
CREATE USER 'dog'@'localhost' IDENTIFIED BY '123456'; 
CREATE USER 'pig'@'192.168.1.101_' IDENDIFIED BY '123456'; 
CREATE USER 'pig'@'%' IDENTIFIED BY '123456'; 
CREATE USER 'pig'@'%' IDENTIFIED BY ''; 
CREATE USER 'pig'@'%';

CREATE USER 'pig'@'%' IDENTIFIED BY '12345678';
GRANT ALL ON *.* TO 'pig'@'%' IDENTIFIED BY '12345678';
flush privileges ;
```


### 授权

说明: privileges - 用户的操作权限,如SELECT , INSERT , UPDATE 等(详细列表见该文最后面).如果要授予所的权限则使用ALL.;databasename - 数据库名,tablename-表名,如果要授予该用户对所有数据库和表的相应操作权限则可用*表示, 如*.*. 

```mysql
GRANT privileges ON databasename.tablename TO 'username'@'host' 

例如：
GRANT SELECT, INSERT ON test.user TO 'pig'@'%'; 
GRANT ALL ON *.* TO 'pig'@'%'; 

```

> 注意:用以上命令授权的用户不能给其它用户授权,如果想让该用户可以授权,用以下命令:

```
GRANT privileges ON databasename.tablename TO 'username'@'host' WITH GRANT OPTION; 
```

### 设置与更改用户密码 

```
当前用户与需要修改密码的用户不是同一用户
SET PASSWORD FOR 'username'@'host' = PASSWORD('newpassword');

当前用户与需要修改密码的用户是同一用户
SET PASSWORD = PASSWORD("newpassword");

例子: SET PASSWORD FOR 'pig'@'%' = PASSWORD("123456"); 
```

### 撤销用户权限 

说明: privilege, databasename, tablename - 同授权部分. 

```
REVOKE privilege ON databasename.tablename FROM 'username'@'host'; 

例子: REVOKE SELECT ON *.* FROM 'pig'@'%';
```

### 删除用户

```
命令: DROP USER 'username'@'host'; 
```

### 修改表名
```
alter table table_name rename table_new_name;
```

### 显示用户权限
```
查看MySQL用户权限：
show grants for 你的用户
比如：
show grants for root@'localhost';

select Host,User from user.user;
```


### 恢复数据
```
mysqlbinlog --no-defaults --database=ff5 --stop-datetime="2017-04-15 21:45:00" /var/lib/mysql/bak/mysql-bin.* > bak_bak_2130.sql
mysqlbinlog --no-defaults --database=ff5 --start-datatime="2017-04-15 21:50:00" --stop-datetime="2017-04-15 21:55:00" /var/lib/mysql/bak/mysql-bin.* > bak_50_55.sql

mysql -uroot -p  -f < bak_1200.sql
```


### mysql查询
```
查询日志目录：select @@log_error;
设置校验强度：
set global validate_password_policy=0;
set global validate_password_policy=1;
set global validate_password_policy=2;

查询校验字符最小长度：
select @@validate_password_length;

flush  privileges ;
然后重新连接数据库
```


- 用户管理　　

- 创建用户
    create user '用户名'@'IP地址' identified by '密码';
- 删除用户
    drop user '用户名'@'IP地址';
- 修改用户
    rename user '用户名'@'IP地址'; to '新用户名'@'IP地址';
- 修改密码
    set password for '用户名'@'IP地址' = Password('新密码')
