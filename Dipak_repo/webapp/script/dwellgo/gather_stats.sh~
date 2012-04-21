#!/bin/bash
LOG_FILE=/var/www/apps/reimatcher/current/log/gather_stats.log
echo "--------------- " `date` "------------------" >> $LOG_FILE
/var/www/apps/reimatcher/current/script/runner 'SiteStatManager.start_gathering' -e production >> $LOG_FILE
