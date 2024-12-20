terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = var.token  
  folder_id = "b1gl7trlm257b69pi8uc"
  zone = var.zone
}

