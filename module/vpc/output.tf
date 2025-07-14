output "public_subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_sg_id" {
  value = aws_security_group.public_sg.id
}
