aws_region = "us-west-2"
project    = "schedule-sync"
environment = "dev"
cloudflare_zone_id = "66c3a47d7eb630244d3e6f3e60f374b5"  # Get this from Cloudflare dashboard
root_domain = "missael.xyz"       # Your domain name in Cloudflare

vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

frontend_image = {
  repository_url = "missaelcorm/schedulesync-web"
  tag           = "latest"
}

backend_image = {
  repository_url = "missaelcorm/schedulesync-api"
  tag           = "latest"
}

certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"