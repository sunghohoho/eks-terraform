output "public_subnet_ids" {
  description = "모듈에서 생성된 public subnet의 id를 output으로 반환합니다."
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "module.vpc.private_subnet_ids와 같이 사용가능"
  value = aws_subnet.private[*].id
}

output "vpc_id" {
  description = "모듈에서 생성된 vpc의 id를 output으로 반환 module.vpc.vpc_id로 사용가능"
  value = aws_vpc.this.id
}