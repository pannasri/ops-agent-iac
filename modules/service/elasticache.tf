# dev 전용 Valkey serverless ElastiCache. 앱 연결 설정은 별도 요청에서 다룬다.
locals {
  elasticache_enabled = local.enabled * (var.environment == "dev" ? 1 : 0)
}

resource "aws_security_group" "elasticache" {
  count       = local.elasticache_enabled
  name        = "${local.name}-elasticache"
  description = "Valkey access from app EC2 only"
  vpc_id      = data.aws_vpc.foundation.id

  tags = { Name = "${local.name}-elasticache" }
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_from_ec2" {
  count                        = local.elasticache_enabled
  security_group_id            = aws_security_group.elasticache[0].id
  referenced_security_group_id = aws_security_group.ec2[0].id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  description                  = "Valkey from app EC2"
}

resource "aws_vpc_security_group_egress_rule" "elasticache_all" {
  count             = local.elasticache_enabled
  security_group_id = aws_security_group.elasticache[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_elasticache_serverless_cache" "elasticache" {
  count                = local.elasticache_enabled
  name                 = "${local.name}-elasticache"
  engine               = "valkey"
  security_group_ids   = [aws_security_group.elasticache[0].id]
  subnet_ids           = aws_subnet.private[*].id

  cache_usage_limits {
    data_storage {
      minimum = 1
      maximum = 1
      unit    = "GB"
    }

    ecpu_per_second {
      minimum = 1000
      maximum = 1000
    }
  }

  tags = { Name = "${local.name}-elasticache" }
}

output "elasticache_endpoint" {
  value = try(aws_elasticache_serverless_cache.elasticache[0].endpoint[0].address, null)
}
