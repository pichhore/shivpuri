#!/bin/bash
LOG_FILE=/var/www/apps/reimatcher/current/log/refresh_featured_profiles.log
echo "--------------- " `date` "------------------" >> $LOG_FILE
/var/www/apps/reimatcher/current/script/runner 'FeaturedProfile.refresh' -e production >> $LOG_FILE