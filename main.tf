locals {
    local_hostname      = "localyeebs.local"
    local_user          = "ubuntu"

    playbook_files      = fileset(path.module, "playbooks/*.yaml")
    config_dir          = "/opt/cfg"
    playbook_dir        = "${local.config_dir}/playbooks"
    playbook_template   = {
        user: local.local_user
        config_dir: local.config_dir
        playbook_dir: local.playbook_dir
        mqtt_dir: "/var/lib/mosquitto"
        mqtt_version: "2.0.14"
        mqtt_port: "1883"

        node_red_dir: "/var/lib/node-red"
        node_red_version: "2.2.2"
        node_red_port: "1880"

        grafana_version: "8.5.6"
        grafana_directory: "/var/lib/grafana"
        grafana_port: "3000"

        postgres_version: "2.7.0-pg14" # Actually TSDB
        postgres_directory: "/var/lib/postgresql/data"
        postgres_user: "dbuser"
        postgres_database: "database"
        postgres_password: var.postgres_password
        postgres_port: "5432"

        house_monitor_version: "1.0.0"
    }
}


data template_file setup_template {
    template = file("${path.module}/templates/setup.template.sh")
    vars = local.playbook_template
}


resource ssh_resource setup_script {
    host        = local.local_hostname
    user        = local.local_user
    private_key = var.local_private_key

    file {
        content     = data.template_file.setup_template.rendered
        destination = "/tmp/setup.sh"
        permissions = "0775" # Executable
    }
    
    triggers = {
        "setup.sh": sha256(data.template_file.setup_template.rendered)
    }

    commands = [
        "sudo bash /tmp/setup.sh"
    ]
}


resource ssh_resource ansible_playbooks {
    host        = local.local_hostname
    user        = local.local_user
    private_key = var.local_private_key

    depends_on = [
        ssh_resource.setup_script
    ]

    dynamic file {
        for_each = local.playbook_files

        content {
            content     = templatefile(file.value, local.playbook_template)
            destination = "${local.playbook_dir}/${basename(file.value)}"
        }
    }
    
    triggers = {
        for f in local.playbook_files : f => sha256(templatefile(f, local.playbook_template))
    }

    # Remote Exec provides better output of ansible-playbook command
    provisioner remote-exec {
        inline = ["ansible-playbook --connection=local ${local.playbook_dir}/setup.yaml"]

        connection {
            host        = local.local_hostname
            type        = "ssh"
            user        = local.local_user
            private_key = var.local_private_key
        }
    }
}
