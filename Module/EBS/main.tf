data "aws_availability_zones" "ebsaz" {
    state = "available"  
}


resource "aws_ebs_volume" "test" {
    availability_zone = data.aws_availability_zones.ebsaz.names[0]
    size = var.size
    
  
}

output "volume_id" {
    value = aws_ebs_volume.test.id
  
}