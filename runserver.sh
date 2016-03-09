#!/bin/sh

MYSQL_CONNECTOR_PACKAGE="mysql-connector-java-5.1.38.tar.gz"
MYSQL_CONNECTOR_DOWNLOAD="http://dev.mysql.com/get/Downloads/Connector-J"
BASH_FILE="/opt/TeamCity/bin/teamcity-server.sh"

if [ ! -f $TEAMCITY_DATA_PATH/lib/jdbc/mysql-connector-java-5.1.38-bin.jar ]; then
    mkdir -p $TEAMCITY_DATA_PATH/lib/jdbc

    # MySQL JDBC connector needed to use MySQL 
    wget $MYSQL_CONNECTOR_DOWNLOAD/$MYSQL_CONNECTOR_PACKAGE
    tar zxf $MYSQL_CONNECTOR_PACKAGE -C $TEAMCITY_DATA_PATH/lib/jdbc
    rm -rf $MYSQL_CONNECTOR_PACKAGE

    mv $TEAMCITY_DATA_PATH/lib/jdbc/mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar $TEAMCITY_DATA_PATH/lib/jdbc/mysql-connector-java-5.1.38-bin.jar
fi

if [ ! -f $TEAMCITY_DATA_PATH/config/internal.properties ]; then
    mkdir -p $TEAMCITY_DATA_PATH/config
    
    cat <<EOF >>$TEAMCITY_DATA_PATH/config/internal.properties
    # Token every agent has to know who wants to self-authenticate
    teamcity.agentAutoAuthorize.authorizationToken=70d44d1e5007dd6b

    # Make sure no "First step" stuff is shown to the user 
    # -> we do configure the database server in this script
    teamcity.startup.maintenance=false
EOF

    # Database server configuration
    cat <<EOF >>$TEAMCITY_DATA_PATH/config/database.properties
connectionProperties.user=$DB_USER
connectionProperties.password=$DB_PASS
connectionUrl=jdbc:mysql://mysql:3306/$DB_NAME
EOF

fi

# Make sure the teamcity-server.sh file is executable
chmod +x $BASH_FILE
cd /home/teamcity-restore
if [ ! -f ./server_is_restored ]; then
    echo "restoring teamcity"
    [ -f restore.sh ] && ./restore.sh
    touch ./server_is_restored
fi
cd -

# Run the TeamCity server
sh $BASH_FILE run

