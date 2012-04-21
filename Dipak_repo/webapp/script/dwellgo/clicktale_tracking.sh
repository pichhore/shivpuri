#!/bin/bash
LOG_FILE=/var/www/apps/reimatcher/current/log/digest_daily.log
echo "--------------- " `date` "------------------" >> $LOG_FILE
find /var/www/apps/reimatcher/current/public/clicktale/ -type f -mmin +30 -exec rm {} \;
