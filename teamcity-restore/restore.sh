#!/bin/bash

backupFile=TeamCity_Backup_20160309_022641.zip

export JAVA_HOME=/usr
rm -rf /etc/teamcity/data/system/*
rm -rf /etc/teamcity/data/config/*
/opt/TeamCity/bin/maintainDB.sh restore -A /etc/teamcity/data -F /home/teamcity-restore/$backupFile -T /home/teamcity-restore/database.properties

