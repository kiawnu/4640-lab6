# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "ubuntu" {
  ami_name      = "web-nginx-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
		  # COMPLETE ME complete the "name" argument below to use Ubuntu 24.04
      name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250115"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] 
	}

  ssh_username = "ubuntu"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    # COMPLETE ME Use the source defined above
    "sources.amazon-ebs.ubuntu"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      "echo set debconf to Noninteractive", 
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo NEEDRESTART_MODE=l apt-get dist-upgrade --yes",
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo mkdir -p /web/html",
      "sudo mkdir -p /etc/nginx/sites-available/",
      "sudo mkdir -p /tmp/web/",
      "mkdir ~/scripts",
      "sudo chown -R ubuntu:ubuntu /web/html ",
      "sudo chown -R ubuntu:ubuntu /etc/nginx/sites-available",
      "sudo chown -R ubuntu:ubuntu /tmp/web",
      "export DEBIAN_FRONTEND=noninteractive"

    ]
  }

  provisioner "file" {
    # COMPLETE ME add the HTML file to your image
    source = "./files/index.html"
    destination = "/web/html/"
  }

  provisioner "file" {
    # COMPLETE ME add the nginx.conf file to your image
    source = "./files/nginx.conf"
    destination = "/tmp/web/"
  }

  # COMPLETE ME add additional provisioners to run shell scripts and complete any other tasks

  provisioner "file" {
    source = "./scripts/"
    destination = "~/scripts"
  }

  provisioner "shell" {
    inline = [
      "cd ~/scripts",
      "sudo chmod +x install-nginx",
      "sudo chmod +x setup-nginx",
      "./install-nginx",
      "./setup-nginx"
    ]
  }

}

