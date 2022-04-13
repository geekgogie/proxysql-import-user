#!/bin/bash
set -f

SOURCE_DB='192.168.40.23'
PROXYSQL_MYSQL_USER='proxysql-paul'
PROXYSQL_MYSQL_PASS='admin' 

SOURCE_PROXYSQL_HOST='192.168.40.23'
SOURCE_PROXYSQL_PORT=6032
PROXYSQL_ADMIN_USER='proxysql-admin'
PROXYSQL_ADMIN_PASSWORD='admin'
MAX_CONN=10000


ask() {
   read -p 'Desired MySQL Username and Localhost: ' uservar
}


ask2() {
   read -p 'Choose desired Hostgroup: ' hgvar 
}


ask

echo 'User is:' $uservar
echo "Verifying user compatibility with script ${uservar} ..."
username=$(echo ${uservar}|cut -d '@' -f 1)
hostname=$(echo ${uservar}|cut -d '@' -f 2)

echo "username: ${username} ... host: ${hostname}"

mapfile pword_res < <(mysql -h${SOURCE_DB} -u${PROXYSQL_MYSQL_USER} -p${PROXYSQL_MYSQL_PASS} --batch -se "SELECT authentication_string FROM mysql.user WHERE user='${username}' and host='${hostname}' and authentication_string like '*%'" 2>/dev/null)

IFS=$'\t' read -r enc_pword <<< "${pword_res[0]}"
#enc_pword=${pword_res[0]}

if [[ $? != 0 ]]; then
   echo "Cannot use this user, password is not using the old mysql_native_password format..."
   exit 0
else
   echo "... user's db password is compatible... "
fi

echo "Verifying user db ${uservar} existence..."
mysql -h${SOURCE_DB} -u${PROXYSQL_MYSQL_USER} -p${PROXYSQL_MYSQL_PASS} -BNse "SHOW GRANTS FOR '${username}'@'${hostname}'\G" 2>/dev/null

if [[ $? == 0 ]]; then
   echo "Checking the available hostgroups in ProxySQL..."
   
   IFS=$'\n'

   mapfile result < <( mysql -h${SOURCE_PROXYSQL_HOST} -u${PROXYSQL_ADMIN_USER} -p${PROXYSQL_ADMIN_PASSWORD} -P${SOURCE_PROXYSQL_PORT} --default-auth=mysql_native_password -se "SELECT writer_hostgroup, reader_hostgroup, comment from runtime_mysql_replication_hostgroups;" 2>/dev/null)
   
   
   IFS=$'\t' read -r col1 col2 col3 <<< "${result[0]}"
   echo "writer hostgroup: ${col1}"
   echo "reader hostgroup: ${col2}"
   echo "comment: ${col3}"
 
   ask2
 
   echo "Inserting user to ProxySQL...."
   mysql --default-auth=mysql_native_password -h${SOURCE_PROXYSQL_HOST} -u${PROXYSQL_ADMIN_USER} -p${PROXYSQL_ADMIN_PASSWORD} -P${SOURCE_PROXYSQL_PORT} \
  	 -e "INSERT INTO mysql_users(username,password,active,default_hostgroup,max_connections) VALUES('${username}','${enc_pword}',1,${hgvar},${MAX_CONN})" 2>/dev/null
   mysql --default-auth=mysql_native_password -h${SOURCE_PROXYSQL_HOST} -u${PROXYSQL_ADMIN_USER} -p${PROXYSQL_ADMIN_PASSWORD} -P${SOURCE_PROXYSQL_PORT} -e "LOAD MYSQL USERS TO RUNTIME;" 2>/dev/null
   mysql --default-auth=mysql_native_password -h${SOURCE_PROXYSQL_HOST} -u${PROXYSQL_ADMIN_USER} -p${PROXYSQL_ADMIN_PASSWORD} -P${SOURCE_PROXYSQL_PORT} -e "SAVE MYSQL USERS TO DISK;" 2>/dev/null

   if [[ $? == 0 ]]; then
      echo "Insert of user success..." 
   else
      echo "Fails to insert the user. Please check your values filled in..."
   fi
else
   echo "User does not exist in db host ${SOURCE_DB}..."
fi
