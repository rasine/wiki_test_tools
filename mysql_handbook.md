### 安装
```
ubuntu
sudo apt-get install mysql-server
sudo apt-get isntall mysql-client
sudo apt-get install libmysqlclient-dev

sudo netstat -tap | grep mysql  检查是否安装成功
```


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

```mysql
GRANT privileges ON databasename.tablename TO 'username'@'host' WITH GRANT OPTION; 
```

### 设置与更改用户密码 

```mysql
当前用户与需要修改密码的用户不是同一用户
SET PASSWORD FOR 'username'@'host' = PASSWORD('newpassword');

当前用户与需要修改密码的用户是同一用户
SET PASSWORD = PASSWORD("newpassword");

例子: SET PASSWORD FOR 'pig'@'%' = PASSWORD("123456"); 
```

### 撤销用户权限 

说明: privilege, databasename, tablename - 同授权部分. 

```mysql
REVOKE privilege ON databasename.tablename FROM 'username'@'host'; 

例子: REVOKE SELECT ON *.* FROM 'pig'@'%';
```

### 删除用户

```mysql
命令: DROP USER 'username'@'host'; 
```

### 修改表名
```mysql
alter table table_name rename table_new_name;
```

### 显示用户权限
```mysql
查看MySQL用户权限：
show grants for 你的用户
比如：
show grants for root@'localhost';

select Host,User from user.user;
```


### 恢复数据
```mysql
mysqlbinlog --no-defaults --database=ff5 --stop-datetime="2017-04-15 21:45:00" /var/lib/mysql/bak/mysql-bin.* > bak_bak_2130.sql
mysqlbinlog --no-defaults --database=ff5 --start-datatime="2017-04-15 21:50:00" --stop-datetime="2017-04-15 21:55:00" /var/lib/mysql/bak/mysql-bin.* > bak_50_55.sql

mysql -uroot -p  -f < bak_1200.sql
```


### mysql查询

```mysql
show full processlist;

查看当前的并发数：show status like 'Threads%';
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| Threads_cached    | 58    |
| Threads_connected | 57    |   ###这个数值指的是打开的连接数
| Threads_created   | 3676  |
| Threads_running   | 4     |   ###这个数值指的是激活的连接数，这个数值一般远低于connected数值
+-------------------+-------+
Threads_connected 跟show processlist结果相同，表示当前连接数。准确的来说，Threads_running是代表当前并发数

查询数据库当前设置的最大连接数：show variables like '%max_connections%';
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 1000  |    ###max_connections 参数可以用于控制数据库的最大连接数：
+-----------------+-------+

查询连接数：show variables like '%connect%';
+--------------------------+-------------------+
| Variable_name            | Value             |
+--------------------------+-------------------+
| character_set_connection | latin1            | 
| collation_connection     | latin1_swedish_ci | 
| connect_timeout          | 10                | 
| init_connect             |                   | 
| max_connect_errors       | 10                | 
| max_connections          | 4000              | 
| max_user_connections     | 0                 | 
+--------------------------+-------------------+

查看mysql的最大连接数：show variables like '%max_connections%';
+-----------------+-------+
| Variable_name  | Value |
+-----------------+-------+
| max_connections | 151  |
+-----------------+-------+

服务器响应的最大连接数：show global status like 'Max_used_connections';
+----------------------+-------+
| Variable_name    | Value |
+----------------------+-------+
| Max_used_connections | 2   |
+----------------------+-------+
```

```mysql
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


### 常用变量有
```
Aborted_clients 由于客户没有正确关闭连接已经死掉，已经放弃的连接数量。
Aborted_connects 尝试已经失败的MySQL服务器的连接的次数。
Connections 试图连接MySQL服务器的次数。
Created_tmp_tables 当执行语句时，已经被创造了的隐含临时表的数量。
Delayed_insert_threads 正在使用的延迟插入处理器线程的数量。
Delayed_writes 用INSERT DELAYED写入的行数。
Delayed_errors 用INSERT DELAYED写入的发生某些错误(可能重复键值)的行数。
Flush_commands 执行FLUSH命令的次数。
Handler_delete 请求从一张表中删除行的次数。
Handler_read_first 请求读入表中第一行的次数。
Handler_read_key 请求数字基于键读行。
Handler_read_next 请求读入基于一个键的一行的次数。
Handler_read_rnd 请求读入基于一个固定位置的一行的次数。
Handler_update 请求更新表中一行的次数。
Handler_write 请求向表中插入一行的次数。
Key_blocks_used 用于关键字缓存的块的数量。
Key_read_requests 请求从缓存读入一个键值的次数。
Key_reads 从磁盘物理读入一个键值的次数。
Key_write_requests 请求将一个关键字块写入缓存次数。
Key_writes 将一个键值块物理写入磁盘的次数。
Max_used_connections 同时使用的连接的最大数目。
Not_flushed_key_blocks 在键缓存中已经改变但是还没被清空到磁盘上的键块。
Not_flushed_delayed_rows 在INSERT DELAY队列中等待写入的行的数量。
Open_tables 打开表的数量。
Open_files 打开文件的数量。
Open_streams 打开流的数量(主要用于日志记载）
Opened_tables 已经打开的表的数量。
Questions 发往服务器的查询的数量。
Slow_queries 要花超过long_query_time时间的查询数量。
Threads_connected 当前打开的连接的数量。
Threads_running 不在睡眠的线程数量。
Uptime 服务器工作了多少秒。
```


### mysql监控
```
检测mysql server是否正常提供服务
mysqladmin -u sky -ppwd -h localhost ping

获取mysql当前的几个状态值
mysqladmin -u sky -ppwd -h localhost status

获取数据库当前的连接信息
mysqladmin -u sky -ppwd -h localhost processlist

获取当前数据库的连接数
mysql -u root -p123456 -BNe “select host,count(host) from processlist group by host;” information_schema

显示mysql的uptime
mysql -e”SHOW STATUS LIKE ‘%uptime%’”|awk ‘/ptime/{ calc = NF/3600;printNF/3600;print(NF-1), calc”Hour” }’

查看数据库的大小
mysql -u root -p123456-e ‘select table_schema,round(sum(data_length+index_length)/1024/1024,4) from information_schema.tables group by table_schema;’

查看某个表的列信息
mysql -u –password= -e “SHOW COLUMNS FROM

” | awk ‘{print 1}' | tr "\n" "," | sed 's/,1}' | tr "\n" "," | sed 's/,//g’
执行mysql脚本
mysql -u user-name -p password < script.sql

mysql dump数据导出
mysqldump -uroot -T/tmp/mysqldump test test_outfile –fields-enclosed-by=\” –fields-terminated-by=,

mysql数据导入
mysqlimport –user=name –password=pwd test –fields-enclosed-by=\” –fields-terminated-by=, /tmp/test_outfile.txt 
LOAD DATA INFILE ‘/tmp/test_outfile.txt’ INTO TABLE test_outfile FIELDS TERMINATED BY ‘”’ ENCLOSED BY ‘,’;

mysql进程监控
ps -ef | grep “mysqld_safe” | grep -v “grep” 
ps -ef | grep “mysqld” | grep -v “mysqld_safe”| grep -v “grep”

查看当前数据库的状态
mysql -u root -p123456 -e ‘show status’

mysqlcheck 工具程序可以检查(check),修 复( repair),分 析( analyze)和优化(optimize)MySQL Server 中的表
mysqlcheck -u root -p123456 –all-databases

mysql qps查询 QPS = Questions(or Queries) / Seconds
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Questions”’ 
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Queries”’

mysql Key Buffer 命中率 key_buffer_read_hits = (1 - Key_reads / Key_read_requests) * 100% key_buffer_write_hits= (1 - Key_writes / Key_write_requests) * 100%
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Key%”’

mysql Innodb Buffer 命中率 innodb_buffer_read_hits=(1-Innodb_buffer_pool_reads/Innodb_buffer_pool_read_requests) * 100%
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Innodb_buffer_pool_read%”’

mysql Query Cache 命中率 Query_cache_hits= (Qcache_hits / (Qcache_hits + Qcache_inserts)) * 100%
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Qcache%”’

mysql Table Cache 状态量
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Open%”’

mysql Thread Cache 命中率 Thread_cache_hits = (1 - Threads_created / Connections) * 100% 正常来说,Thread Cache 命中率要在 90% 以上才算比较合理。
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Thread%”’

mysql 锁定状态:锁定状态包括表锁和行锁两种,我们可以通过系统状态变量获得锁定总次数,锁定造成其他线程等待的次数,以及锁定等待时间信息
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “%lock%”’

mysql 复制延时量 在slave节点执行
mysql -u root -p123456 -e ‘SHOW SLAVE STATUS’

mysql Tmp table 状况 Tmp Table 的状况主要是用于监控 MySQL 使用临时表的量是否过多,是否有临时表过大而不得不从内存中换出到磁盘文件上
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Created_tmp%”’

mysql Binlog Cache 使用状况:Binlog Cache 用于存放还未写入磁盘的 Binlog 信 息 。
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Binlog_cache%”’

mysql nnodb_log_waits 量:Innodb_log_waits 状态变量直接反应出 Innodb Log Buffer 空间不足造成等待的次数
mysql -u root -p123456 -e ‘SHOW /!50000 GLOBAL / STATUS LIKE “Innodb_log_waits’
```

### 实时监控SQL语句的执行频率
```
mysqladmin -Pxxxx -uxxxx -pxxxx -hxxxx -r -i 1 ext |\
awk -F"|" \
"BEGIN{ count=0; }"\
'{ if($2 ~ /Variable_name/ && ++count == 1){\
    print "----------|---------|--- MySQL Command Status --|----- Innodb row operation ----|-- Buffer Pool Read --";\
    print "---Time---|---QPS---|select insert update delete|  read inserted updated deleted|   logical    physical";\
}\
else if ($2 ~ /Queries/){queries=$3;}\
else if ($2 ~ /Com_select /){com_select=$3;}\
else if ($2 ~ /Com_insert /){com_insert=$3;}\
else if ($2 ~ /Com_update /){com_update=$3;}\
else if ($2 ~ /Com_delete /){com_delete=$3;}\
else if ($2 ~ /Innodb_rows_read/){innodb_rows_read=$3;}\
else if ($2 ~ /Innodb_rows_deleted/){innodb_rows_deleted=$3;}\
else if ($2 ~ /Innodb_rows_inserted/){innodb_rows_inserted=$3;}\
else if ($2 ~ /Innodb_rows_updated/){innodb_rows_updated=$3;}\
else if ($2 ~ /Innodb_buffer_pool_read_requests/){innodb_lor=$3;}\
else if ($2 ~ /Innodb_buffer_pool_reads/){innodb_phr=$3;}\
else if ($2 ~ /Uptime / && count >= 2){\
  printf(" %s |%9d",strftime("%H:%M:%S"),queries);\
  printf("|%6d %6d %6d %6d",com_select,com_insert,com_update,com_delete);\
  printf("|%6d %8d %7d %7d",innodb_rows_read,innodb_rows_inserted,innodb_rows_updated,innodb_rows_deleted);\
  printf("|%10d %11d\n",innodb_lor,innodb_phr);\
}}'
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
