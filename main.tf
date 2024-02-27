terraform {
  required_providers {
    libvirt = {
     source = "local/dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  # Configuration options
  uri = "qemu:///system"
  #alias = "server2"
  #uri   = "qemu+ssh://root@192.168.100.10/system"
}

#resource "libvirt_cloudinit_disk" "commoninit" {
#  #name           = "commoninit.iso"
#  #user_data      = data.template_file.user_data.rendered
#  network_config = data.template_file.network_config.rendered
#  #pool           = libvirt_pool.ubuntu.name
#}

#data "template_file" "network_config" {
#  template = file("${path.module}/network_config.cfg")
#}

# Defining VM Volume
resource "libvirt_volume" "jammy-server-qcow2" {
  name = "jammy-server.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "/run/media/deck/c8dd7f24-b285-4d77-9883-57305fd3dc1d/kvm_dir_images_pool/jammy-server-cloudimg-amd64.img_orig"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "jammy-server" {
  name   = "jammy-server"
  memory = "2048"
  vcpu   = 2



  network_interface {
    network_name = "default" # List networks with virsh net-list
  }



  disk {
    volume_id = "${libvirt_volume.jammy-server-qcow2.id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
output "ip" {
  value = "${libvirt_domain.jammy-server.network_interface.0.addresses.0}"
}