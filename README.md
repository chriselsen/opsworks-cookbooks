# AWS Opsworks Cookbooks


The following custom Chef cookbooks are available to be used with [AWS OpsWorks](http://aws.amazon.com/opsworks/).

## AWS-Ubuntu

Configure an AWS Opsworks Ubuntu image with a swapspace. This is aimed at t1.micro instances to prevent "out of memory" issues.

Available recipes for [AWS OpsWorks Lifecycle Events](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-events.html):
* **Setup**: aws-ubuntu::setup; Adds memory swap


## Wordpress

Configure Wordpress to interact with the MySQL server. It can be used for a fresh install or a restore from a Backup using [BackWPup](http://wordpress.org/plugins/backwpup/).

Available recipes for [AWS OpsWorks Lifecycle Events](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-events.html):
* **Configure**: wordpress::configure; Create wp-config.php file along with Cronjob


## Other
All other cookbooks are currently in a work-in-progress state and might not work.
