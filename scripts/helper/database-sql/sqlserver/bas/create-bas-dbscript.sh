#!/BIN/BASH

###############################################################################
#
# LICENSED MATERIALS - PROPERTY OF IBM
#
# (C) COPYRIGHT IBM CORP. 2022. ALL RIGHTS RESERVED.
#
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION OR
# DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH IBM CORP.
#
###############################################################################

# function for creating the db sql statement file for Business Automation Studio database
function create_bas_studio_db_sqlserver_sql_file(){
    dbname=$1
    dbuser=$2
    dbuserpwd=$3
    dbserver=$4
    # remove quotes from beginning and end of string
    dbname=$(sed -e 's/^"//' -e 's/"$//' <<<"$dbname")
    dbuser=$(sed -e 's/^"//' -e 's/"$//' <<<"$dbuser")
    dbuserpwd=$(sed -e 's/^"//' -e 's/"$//' <<<"$dbuserpwd")
    dbserver=$(sed -e 's/^"//' -e 's/"$//' <<<"$dbserver")

    mkdir -p $BAS_DB_SCRIPT_FOLDER/$DB_TYPE/$dbserver >/dev/null 2>&1
    rm -rf $BAS_DB_SCRIPT_FOLDER/$DB_TYPE/$dbserver/create_bas_studio_db.sql
cat << EOF > $BAS_DB_SCRIPT_FOLDER/$DB_TYPE/$dbserver/create_bas_studio_db.sql
-- create bastudio database
CREATE DATABASE ${dbname} COLLATE SQL_Latin1_General_CP1_CI_AS;;
ALTER DATABASE ${dbname} SET READ_COMMITTED_SNAPSHOT ON;

-- create a SQL Server login account for the database user of each of the databases and update the master database to grant permission for XA transactions for the login account
USE MASTER
GO
-- when using SQL authentication
CREATE LOGIN ${dbuser} WITH PASSWORD='${dbuserpwd}'
-- when using Windows authentication:
-- CREATE LOGIN [domain\user] FROM WINDOWS
GO
CREATE USER ${dbuser} FOR LOGIN ${dbuser} WITH DEFAULT_SCHEMA=${dbuser}
GO
EXEC sp_addrolemember N'SqlJDBCXAUser', N'${dbuser}';
GO

-- Creating users and schemas for bastudio database
USE ${dbname}
GO
CREATE USER ${dbuser} FOR LOGIN ${dbuser} WITH DEFAULT_SCHEMA=${dbuser}
GO
CREATE SCHEMA ${dbuser} AUTHORIZATION ${dbuser}
GO
EXEC sp_addrolemember 'db_ddladmin', ${dbuser};
EXEC sp_addrolemember 'db_datareader', ${dbuser};
EXEC sp_addrolemember 'db_datawriter', ${dbuser};
GO
EOF
}
