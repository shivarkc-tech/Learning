# ═══════════════════════════════════════════════════════════════
# DATA SOURCES — AVAILABILITY ZONES
# ═══════════════════════════════════════════════════════════════

# Resolve available AZs dynamically — no hard-coding needed
data "aws_availability_zones" "available" {
  state = "available"
}

# ═══════════════════════════════════════════════════════════════
# VPC
# ═══════════════════════════════════════════════════════════════

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  # Required for SSM Session Manager endpoint resolution
  enable_dns_support   = true

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

# ═══════════════════════════════════════════════════════════════
# INTERNET GATEWAY  (public subnet ↔ internet)
# ═══════════════════════════════════════════════════════════════

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-igw"
  })
}

# ═══════════════════════════════════════════════════════════════
# SUBNETS
# ═══════════════════════════════════════════════════════════════

# Public subnet — internet-accessible via the IGW
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false  # Controlled per-instance via associate_public_ip

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-public-subnet"
    Tier = "Public"
  })
}

# Private subnet — no direct internet route (no NAT GW for lab cost savings)
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-private-subnet"
    Tier = "Private"
  })
}

# ═══════════════════════════════════════════════════════════════
# ROUTE TABLES
# ═══════════════════════════════════════════════════════════════

# ── Public route table — default route via IGW ─────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── Private route table — local routes only (no NAT GW) ────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # No default route — private subnet is intentionally isolated
  # Add a NAT Gateway route here later when moving to production

  tags = merge(local.common_tags, var.additional_tags, {
    Name = "${var.project}-${var.environment}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
