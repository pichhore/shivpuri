#!/bin/bash
LOG_FILE=/var/www/apps/reimatcher/current/log/digest_weekly.log
echo "--------------- " `date` "------------------" >> $LOG_FILE
/var/www/apps/reimatcher/current/script/runner 'MessageEngine.send_messages(Time.now,:weekly)' -e production >> $LOG_FILE