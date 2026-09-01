#создаем облачную сеть
module "vpc" {
  source = "../../vpc"

  name           = "develop"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.1.0/24"]
}

module "test-vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

  env_name      = "develop"
  network_id    = module.vpc.network_id
  subnet_zones  = ["ru-central1-a"]
  subnet_ids    = [module.vpc.subnet_id]

  instance_name = "webs"
  instance_count = 2
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    owner   = "i.ivanov"
    project = "marketing"
  }

  metadata = {
    user-data         = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}

module "example-vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "stage"
  network_id   = module.vpc.network_id
  subnet_zones = ["ru-central1-a"]
  subnet_ids   = [module.vpc.subnet_id]
  instance_name  = "web-stage"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

    labels = { 
    owner= "i.ivanov",
    project = "analytics"
     }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }

}

#Пример передачи cloud-config в ВМ для демонстрации №3
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
  }
}
