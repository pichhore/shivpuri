#!/bin/bash
LOG_FILE=/var/www/apps/reimatcher/current/log/alerts.log
echo "--------------- " `date` "------------------" >> $LOG_FILE
/var/www/apps/reimatcher/current/script/runner 'AlertEngine.process()' -e production >> $LOG_FILE