# EC2 Auto-Healer with CloudWatch + Slack Alerts + Alarms

A real-world, production-ready automation tool that monitors critical services on an EC2 instance, auto-restarts them if they fail, logs the results, sends Slack alerts, and pushes logs to AWS CloudWatch for centralized monitoring and alarming.

---

## 💡 Why Use This Project?

In real-world production environments, application uptime and service health are non-negotiable. This tool ensures:

* 🔁 **Auto-healing:** Automatically detects and recovers failed services.
* 📊 **Observability:** Integrates with AWS CloudWatch for centralized log tracking and metrics.
* 🔔 **Alerting:** Sends real-time Slack notifications to reduce detection and response time.
* 📈 **Proactive Monitoring:** CloudWatch alarms alert you before failures escalate.
* 🧩 **Customizable:** Add or remove services via `config.txt`, easily extendable to more tooling.

### ✅ Ideal For:

* Production EC2 workloads
* Internal DevOps tooling
* Self-healing environments
* For real-world automation & alerting

---

## 📁 Project Structure

```
ec2-auto-healer/
├── service-watchdog.sh              # Main monitoring & healing script
├── config.txt                       # List of service names to monitor (e.g., nginx, docker)
├── logs/
│   ├── service-check.log            # Log file of service status & actions
│   └── cron-output.log              # (Optional) Output from cron job
└── cloudwatch-config.json           # CloudWatch agent config (for Ubuntu)
```

---

## 🔧 Features

* Monitors services listed in `config.txt`
* Restarts them if down
* Logs each check to `logs/service-check.log`
* Sends real-time Slack alerts on failure/recovery
* Ships logs to AWS CloudWatch using the Unified Agent
* Triggers CloudWatch alarms if failures exceed thresholds

---

## 🧪 Prerequisites

* EC2 instance (Ubuntu 22.04)
* IAM role with `CloudWatchAgentServerPolicy`
* Slack webhook URL (for alerts)

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/ec2-auto-healer.git
cd ec2-auto-healer
```

### 2. Set Executable Permissions

```bash
chmod +x service-watchdog.sh
```

### 3. Edit Your Service List

```bash
echo -e "nginx\ndocker" > config.txt
```

### 4. Add Slack Webhook in Script

Edit `service-watchdog.sh` and update this line:

```bash
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXX/YYYY/ZZZZ"
```

### 5. Create Logs Folder

```bash
mkdir -p logs
```

### 6. Test the Script Manually

```bash
sudo ./service-watchdog.sh
```

### 7. Schedule as a Cron Job (root user)

```bash
sudo crontab -e
```

Add:

```
*/5 * * * * /root/ec2-auto-healer/service-watchdog.sh >> /root/ec2-auto-healer/logs/cron-output.log 2>&1
```

---

## ☁️ CloudWatch Integration

### 1. Install CloudWatch Agent (Ubuntu)

```bash
cd /tmp
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
```

### 2. Create CloudWatch Config

Save this to `cloudwatch-config.json`:

```json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/root/ec2-auto-healer/logs/service-check.log",
            "log_group_name": "/ec2/service-watchdog",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
```

### 3. Start the Agent

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/root/ec2-auto-healer/cloudwatch-config.json \
  -s
```

---

## 🚨 CloudWatch Alarm Setup (Optional but Recommended)

### 1. Create a Metric Filter

* Go to CloudWatch > Log groups > `/ec2/service-watchdog`
* Click **Create metric filter**
* Pattern: `Failed to restart`
* Metric Namespace: `EC2ServiceWatchdog`
* Metric Name: `FailedRestarts`

### 2. Create Alarm

* Go to CloudWatch > Alarms > Create alarm
* Select Metric: `EC2ServiceWatchdog > FailedRestarts`
* Condition: If > 3 in 5 minutes
* Notification: Send email/SNS alert

---

## 🔐 IAM Permissions Required

Attach this to your EC2 IAM role:

```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ],
  "Resource": "*"
}
```
---

## 🏷️ Tags

`AWS` `EC2` `CloudWatch` `DevOps` `Slack` `Automation` `Alarms` `ShellScript`

