# HOW TO USE
To use this, I have a simple usage on how do I use it:
```
[root@pupnode23 ~]# ./proxysql-import-user.sh
Desired MySQL Username and Localhost: maximusdb@192.168.40.%
User is: maximusdb@192.168.40.%
Verifying user compatibility with script maximusdb@192.168.40.% ...
username: maximusdb ... host: 192.168.40.%
... user's db password is compatible...
Verifying user db maximusdb@192.168.40.% existence...
*************************** 1. row ***************************
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER, CREATE TABLESPACE, CREATE ROLE, DROP ROLE ON *.* TO `maximusdb`@`192.168.40.%`
*************************** 2. row ***************************
GRANT APPLICATION_PASSWORD_ADMIN,AUDIT_ADMIN,BACKUP_ADMIN,BINLOG_ADMIN,BINLOG_ENCRYPTION_ADMIN,CLONE_ADMIN,CONNECTION_ADMIN,ENCRYPTION_KEY_ADMIN,FLUSH_OPTIMIZER_COSTS,FLUSH_STATUS,FLUSH_TABLES,FLUSH_USER_RESOURCES,GROUP_REPLICATION_ADMIN,INNODB_REDO_LOG_ARCHIVE,INNODB_REDO_LOG_ENABLE,PERSIST_RO_VARIABLES_ADMIN,REPLICATION_APPLIER,REPLICATION_SLAVE_ADMIN,RESOURCE_GROUP_ADMIN,RESOURCE_GROUP_USER,ROLE_ADMIN,SERVICE_CONNECTION_ADMIN,SESSION_VARIABLES_ADMIN,SET_USER_ID,SHOW_ROUTINE,SYSTEM_USER,SYSTEM_VARIABLES_ADMIN,TABLE_ENCRYPTION_ADMIN,XA_RECOVER_ADMIN ON *.* TO `maximusdb`@`192.168.40.%`
Checking the available hostgroups in ProxySQL...
writer hostgroup: 10
reader hostgroup: 20
comment: test repl 1
Choose desired Hostgroup: 10
Inserting user to ProxySQL....
Insert of user success...
```

# VERIFY
Then I can verify that the user works,
```
[root@pupnode23 ~]# mysql --default-auth=mysql_native_password -h127.0.0.1 -umaximusdb -pmaximuspword -P6033
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1292
Server version: 5.5.30 (ProxySQL)


Copyright (c) 2009-2021 Percona LLC and/or its affiliates
Copyright (c) 2000, 2021, Oracle and/or its affiliates.


Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.


Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.


mysql> select @@hostname;
+------------+
| @@hostname |
+------------+
| pupnode24  |
+------------+
1 row in set (0.00 sec)


mysql> select database();
+--------------------+
| database()        |
+--------------------+
| information_schema |
+--------------------+
1 row in set (0.01 sec)
```


# SEQUENCE OF THE SCRIPT
The sequence of the script simply ask you to
- input the username with the hostname. i.e. make sure you add the username and hostname like for example,
maximusdb@192.168.40.32 for example or maximusdb@192.168.% or maximusdb@localhost or maximusdb@127.0.0.1 ...
- then choose the desired hostgroup. The hostgroup will be retrieved and displayed all you have to do is make sure that you input the correct HG then.

