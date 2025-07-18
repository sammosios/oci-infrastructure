data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

resource "oci_core_vcn" "k0s_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "k0s-vcn"
}

resource "oci_core_internet_gateway" "k0s_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k0s_vcn.id
  display_name   = "k0s-igw"
}

resource "oci_core_route_table" "k0s_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k0s_vcn.id
  display_name   = "k0s-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.k0s_igw.id
  }
}

resource "oci_core_security_list" "k0s_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.k0s_vcn.id
  display_name   = "k0s-security-list"

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = oci_core_vcn.k0s_vcn.cidr_block
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 8 # Echo Request
      code = 0
    }
  }

  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = oci_core_vcn.k0s_vcn.cidr_block
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 3 # Destination Unreachable
      code = 4 # Fragmentation Needed and Don't Fragment Bit Set
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "k0s_subnet" {
  cidr_block        = "10.0.1.0/24"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.k0s_vcn.id
  display_name      = "k0s-subnet"
  route_table_id    = oci_core_route_table.k0s_route_table.id
  security_list_ids = [oci_core_security_list.k0s_security_list.id]
  dhcp_options_id   = oci_core_vcn.k0s_vcn.default_dhcp_options_id
}

resource "oci_core_instance" "k0s_controller_amd" {
  count               = var.architecture == "amd" ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "k0s-controller-amd"
  shape               = var.amd_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.k0s_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_id   = var.ubuntu_amd_image_id
    source_type = "image"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(templatefile("${path.module}/k0s-controller-init.yaml.tpl", {}))
  }
}

resource "oci_core_instance" "k0s_worker_amd" {
  count               = var.architecture == "amd" ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "k0s-worker-amd"
  shape               = var.amd_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.k0s_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_id   = var.ubuntu_amd_image_id
    source_type = "image"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(templatefile("${path.module}/k0s-worker-init.yaml.tpl", {}))
  }
}

resource "oci_core_instance" "k0s_controller_arm" {
  count               = var.architecture == "arm" ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "k0s-controller-arm"
  shape               = var.arm_shape
  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k0s_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_id   = var.ubuntu_arm_image_id
    source_type = "image"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(templatefile("${path.module}/k0s-controller-init.yaml.tpl", {}))
  }
}

resource "oci_core_instance" "k0s_worker_arm" {
  count               = var.architecture == "arm" ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "k0s-worker-arm"
  shape               = var.arm_shape
  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k0s_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_id   = var.ubuntu_arm_image_id
    source_type = "image"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(templatefile("${path.module}/k0s-worker-init.yaml.tpl", {}))
  }
}


output "k0s_controller_public_ip" {
  value = var.architecture == "amd" ? oci_core_instance.k0s_controller_amd[0].public_ip : oci_core_instance.k0s_controller_arm[0].public_ip
}

output "k0s_worker_public_ip" {
  value = var.architecture == "amd" ? oci_core_instance.k0s_worker_amd[0].public_ip : oci_core_instance.k0s_worker_arm[0].public_ip
}


