#!/bin/bash
LOG_FILE=/var/www/apps/reimatcher/current/log/digest_monthly.log
echo "--------------- " `date` "------------------" >> $LOG_FILE
/var/www/apps/reimatcher/current/script/runner 'MessageEngine.send_messages(Time.now,:monthly)' -e production >> $LOG_FILE