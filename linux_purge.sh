#!/usr/bin/env bash

sudo apt install secure-delete

# copy the script to a specific folder and edit the crontab for startup execution : "@reboot bash linux_purge.sh"

#change network interface here
inter="wlp4s0"

LOGS_FILES=(
        /var/log/lastlog         
        /var/log/messages         
        /var/log/warn         
        /var/log/wtmp         
        /var/log/poplog         
        /var/log/qmail         
        /var/log/smtpd         
        /var/log/telnetd         
        /var/log/secure         
        /var/log/auth         
        /var/log/auth.log         
        /var/log/cups/access_log         
        /var/log/cups/error_log         
        /var/log/thttpd_log         
        /var/log/spooler         
        /var/spool/tmp         
        /var/spool/errors         
        /var/spool/locks         
        /var/log/nctfpd.errs         
        /var/log/acct         
        /var/apache/log         
        /var/apache/logs         
        /usr/local/apache/log         
        /usr/local/apache/logs         
        /usr/local/www/logs/thttpd_log         
        /var/log/news         
        /var/log/news/news         
        /var/log/news.all         
        /var/log/news/news.all         
        /var/log/news/news.crit         
        /var/log/news/news.err         
        /var/log/news/news.notice         
        /var/log/news/suck.err         
        /var/log/news/suck.notice         
        /var/log/xferlog         
        /var/log/proftpd/xferlog.legacy         
        /var/log/proftpd.xferlog         
        /var/log/proftpd.access_log         
        /var/log/httpd/error_log         
        /var/log/httpsd/ssl_log         
        /var/log/httpsd/ssl.access_log         
        /var/adm         
        /var/run/utmp         
        /etc/wtmp         
        /etc/utmp         
        /etc/mail/access         
        /var/log/mail/info.log         
        /var/log/mail/errors.log         
        /var/log/httpd/*_log         
        /var/log/ncftpd/misclog.txt         
        /var/account/pacct         
        /var/log/snort         
        /var/log/bandwidth         
        /var/log/explanations         
        /var/log/syslog         
        /var/log/user.log         
        /var/log/daemons/info.log         
        /var/log/daemons/warnings.log         
        /var/log/daemons/errors.log         
        /etc/httpd/logs/error_log         
        /etc/httpd/logs/*_log         
        /var/log/mysqld/mysqld.log
        /root/.ksh_history         
        /root/.bash_history         
        /root/.sh_history         
        /root/.history         
        /root/*_history         
        /root/.login         
        /root/.logout         
        /root/.bash_logut         
        /root/.Xauthority
        /var/log/messages
        /var/log/auth.log
        /var/log/kern.log
        /var/log/cron.log
        /var/log/maillog
        /var/log/boot.log
        /var/log/mysqld.log
        /var/log/qmail
        /var/log/httpd
        /var/log/lighttpd
        /var/log/secure
        /var/log/utmp
        /var/log/wtmp
        /var/log/yum.log
        /var/log/system.log
        /var/log/DiagnosticMessages
        /Library/Logs
        /Library/Logs/DiagnosticReports
        ~/Library/Logs
        ~/Library/Logs/DiagnosticReports
)

function disableAuth () {
        if [ -w /var/log/auth.log ]; then
                ln /dev/null /var/log/auth.log -sf
        fi
}

function disableHistory () {
        ln /dev/null ~/.bash_history -sf

        if [ -f ~/.zsh_history ]; then
                ln /dev/null ~/.zsh_history -sf
        fi

        export HISTFILESIZE=0
        export HISTSIZE=0

        set +o history
}


function clearLogs () {
        for i in "${LOGS_FILES[@]}"
        do
                if [ -f "$i" ]; then
                        if [ -w "$i" ]; then
                                srm -dfl "$i"
                        fi
                elif [ -d "$i" ]; then
                        if [ -w "$i" ]; then
                                srm -dfl "${i:?}"/*
                        fi
                fi
        done
}

function clearHistory () {
        if [ -f ~/.zsh_history ]; then
                srm -dfl ~/.zsh_history
        fi

        srm -dfl ~/.bash_history

        history -c
}

clearLogs &
clearHistory &
disableAuth &
disableHistory &

sudo ifconfig ${inter} down
sudo macchanger -r ${inter}
sudo ifconfig ${inter} up

sudo sync
sudo echo 3 > /proc/sys/vm/drop_caches
sudo swapoff -a
sudo swapon -a

sudo systemctl disable systemd-journald.service
sudo service rsyslog stop
sudo systemctl disable rsyslog
sudo /etc/init.d/syslogd stop
sudo systemctl disable syslog

echo " comment out this line -> $IncludeConfig /etc/rsyslog.d/*.conf"

path_logs=$(find /var/log/ -name "*")
for i in $path_logs
do
   sudo srm -dflr $i
done

sudo sdmem -f

