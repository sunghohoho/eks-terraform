terraform {
  required_version = ">= 0.13"

  required_providers {
   kubectl = {
      source  = "alekc/kubectl"
      version = ">=2.1.2"
    }
  }
}