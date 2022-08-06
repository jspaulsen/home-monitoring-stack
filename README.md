# home-monitoring-stack

## Home Monitoring and Automation
Home Monitoring and Automation is an ansible provisioned, docker-compose run stack of images for monitoring and automation.

### Monitoring and Visualization

* [House Monitor Sub](https://github.com/jspaulsen/house-monitor/tree/develop/house_monitor_sub) is used to subscribe to an MQTT with Tasmota sensor devices and publish them to Timescale.
* Grafana is used to visualize data within Timescale

### Automation

* Node Red is used for automation, typically via MQTT

## Required Tools

* terraform

## Deployment Targets

This has been run and tested against on a Raspberry Pi 4B running Ubuntu Server 22.04.  In theory, this should run against any target
with comparable specs and configuration.  If run against a "cloud" target, it might be worth refactoring to make `setup.sh` run as part of cloud-init.

## Configuration and Deployment

This stack is designed to run locally but with some changes can likely be made to run a remote, cloud based solution (e.g., AWS EC2 or DigitalOcean droplet).

### Preqrequisite

`home-monitoring-stack` is designed to be deployed by terraform and remotely run ansible to provision the machine.  All configuration files are copied over via a ssh terraform provider.  As such, if running locally, it is necessary to do minor configuration ahead of time.

**These prerequisite steps _must_ be performed before attempting deployment**

#### Machine Hostname and User

* Set hostname and user of machine being provisioned in `main.tf` locals block
    * local_hostname
    * local_user

#### Local Machine Configuration

* Generate a new ssh key _for use with terraform_ and install on the remote machine. See [ssh-copy-id](https://www.ssh.com/academy/ssh/copy-id) for more information.
    * It is _imperative_ you keep the remote key for now; this is used for all future deployment

* Configure the user for passwordless sudo.  See [this](https://linuxconfig.org/configure-sudo-without-password-on-ubuntu-20-04-focal-fossa-linux) for more information

### Terraform Configuration

It is necessary to change the terraform backend (in `backend.tf`) to reflect your terraform backend; `home-monitoring-stack` by default uses Terraform Cloud but any backend should work.

#### Terraform Cloud

Login via `terraform login` and follow the directions prior to initial deployment.

### Terraform Variables

The following terraform variables are required for deployment:

* `local_private_key` - This _must_ be the contents of the private key generated in the [earlier](#local-machine-configuration) prerequisite configuration.  This can be stored in an environment variable.

* `postgres_password` - Postgres password used by Timescale database.


It is recommended these values be stored in a `.env` file to be sourced and provided by environment variables prior to deployment.  This can be done by prefixing `TF_VAR_` to the terraform.

Example:

```shell
export TF_VAR_local_private_key=""
export TF_VAR_postgres_password=""
```

### Stack Configuration

Some aspects of the deployed configuration can be configured via the locals block in `main.tf`:

* ports
* directories (both for mounted volumes and for configuration directory)
* docker image versions

### Deployment

Once the [prerequisite](#preqrequisite) configuration, [terraform configuration](#terraform-configuration) configuration and [terraform variables](#terraform-variables) are available and any optional changes made to the [stack configuration](#stack-configuration), terraform deploy can occur

```shell
terraform init
terraform deploy
```

