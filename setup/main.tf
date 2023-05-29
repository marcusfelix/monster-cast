terraform {
  required_providers {
    fly = {
      source = "fly-apps/fly"
      version = "0.0.21"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

variable "slug" {
  type = string
}

variable "domain" {
  type = string
}

variable "region" {
  type = string
}

variable "image" {
  type = string
}

variable "size" {
  type = number
}

variable "cloudflare_api_token" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "fly_api_token" {
  type = string
}

provider "fly" {
  fly_api_token = var.fly_api_token
  useinternaltunnel    = true
  internaltunnelorg    = "personal"
  internaltunnelregion = "ams"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "fly_app" "app" {
  name = var.slug
}

resource "fly_ip" "ipv4" {
  app  = var.slug
  type = "v4"

  depends_on = [ fly_app.app ]
}

resource "fly_ip" "ipv6" {
  app  = var.slug
  type = "v6"

  depends_on = [ fly_app.app ]
}

resource "fly_cert" "cert" {
  app      = var.slug
  hostname = var.domain

  depends_on = [ fly_app.app ]
}

resource "fly_machine" "machine" {
  app    = var.slug
  region = var.region
  name   = var.slug
  image  = var.image
  env = {
    
  }
  services = [
    {
      ports = [
        {
          port     = 443
          handlers = ["tls", "http"]
        },
        {
          port     = 80
          handlers = ["http"]
        }
      ]
      "protocol" : "tcp",
      "internal_port" : 8090
    }
  ]
  cpus = 1
  memorymb = 256
  depends_on = [ fly_app.app ]
}

resource "fly_volume" "volume" {
  count = var.size

  app  = var.slug
  name = "data"
  size = var.size
  region = var.region

  depends_on = [ fly_app.app ]
}

// Create Cloudflare DNS record
resource "cloudflare_record" "record" {
  zone_id = var.cloudflare_zone_id
  name    = var.domain
  value   = fly_ip.ipv4.address
  type    = "A"
  ttl     = 1
  proxied = false
}