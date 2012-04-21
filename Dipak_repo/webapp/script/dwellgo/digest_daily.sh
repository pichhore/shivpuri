#!/bin/bash
LOG_FILE=/var/www/apps/reimatcher/current/log/digest_daily.log
echo "--------------- " `date` "------------------" >> $LOG_FILE
/var/www/apps/reimatcher/current/script/runner 'MessageEngine.send_messages(Time.now,:daily)' -e production >> $LOG_FILE