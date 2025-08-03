

#!/bin/bash
PATH=/usr/sbin:/usr/bin:/bin:/sbin

SERVICES=$(cat /root/ec2-auto-healer/config.txt)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
LOGFILE="/root/ec2-auto-healer/logs/service-check.log"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"

for SERVICE in $SERVICES; do
	    /bin/systemctl is-active --quiet $SERVICE
	        if [ $? -ne 0 ]; then
			        echo "$TIMESTAMP: $SERVICE is down! Restarting..." | tee -a $LOGFILE
				        /bin/systemctl restart $SERVICE

					        if [ $? -eq 0 ]; then
							            STATUS_MSG="✅ $SERVICE restarted successfully on $(hostname)"
								            else
										                STATUS_MSG="⚠️ Failed to restart $SERVICE on $(hostname)"
												        fi

													        /usr/bin/curl -X POST -H 'Content-type: application/json' \
															             --data "{\"text\":\"$STATUS_MSG\"}" \
																                  $SLACK_WEBHOOK_URL
														    else
															            echo "$TIMESTAMP: $SERVICE is running fine." >> $LOGFILE
																        fi
																done

