################################################################
## Archivo de configuración de Networking - Proyecto Final SE ##
## networking.tf					                                    ##
################################################################

## Creación de VPC en AWS para el Proyecto Final
resource "aws_vpc" "vpcProyFinal" {
  cidr_block = "40.0.0.0/24"
  tags = {
    Name = "vpcProyFinal"
  }
}

## Creación de Subred1 en AWS para el Proyecto Final
resource "aws_subnet" "subnetproyfinal1" {
  vpc_id                  = aws_vpc.vpcProyFinal.id
  cidr_block              = "40.0.0.0/28"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "subnetProyFinal1"
  }
}

## Creación de Subred2 en AWS para el Proyecto Final
resource "aws_subnet" "subnetproyfinal2" {
  vpc_id                  = aws_vpc.vpcProyFinal.id
  cidr_block              = "40.0.0.16/28"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "subnetProyFinal2"
  }
}

## Creación Internet Gateway en AWS para el Proyecto Final
resource "aws_internet_gateway" "igwProyFinal" {
  vpc_id = aws_vpc.vpcProyFinal.id
  tags = {
    Name = "igwProyFinal"
  }
}

## Creación de Tabla de Rutas en AWS para el Proyecto Final
resource "aws_route_table" "rtProyFinal" {
  vpc_id = aws_vpc.vpcProyFinal.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwProyFinal.id
  }
  tags = {
    Name = "rtProyFinal"
  }
}

# Se crea Rutas Publicas
resource "aws_route_table_association" "rt_public_1" {
  subnet_id = aws_subnet.subnetproyfinal1.id
  route_table_id= aws_route_table.rtProyFinal.id
}
resource "aws_route_table_association" "rt_public_2" {
  subnet_id = aws_subnet.subnetproyfinal2.id
  route_table_id= aws_route_table.rtProyFinal.id
}

## Creación de Grupo de Seguridad en AWS para el Proyecto Final
resource "aws_security_group" "ecs_sg_ProyFinal" {
  name_prefix = "ecs_sg_ProyFinal"
  description = "Allow all traffic within the VPC"
  vpc_id      = aws_vpc.vpcProyFinal.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.lb_sg_ProyFinal.id] # Acceso de trafico desde un security group
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## Creación de Grupo de Seguridad en AWS para el Load Balancer Proyecto Final
resource "aws_security_group" "lb_sg_ProyFinal" {
  name_prefix = "lb_sg_ProyFinal"
  description = "Allow all traffic within the VPC"
  vpc_id      = aws_vpc.vpcProyFinal.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Acceso de trafico desde cualquier IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Creación de Balanceador de Carga en AWS para el Proyecto Final
resource "aws_lb" "lb-proyfinal" {
  name               = "loadBalancer-ProyFinal"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnetproyfinal1.id,aws_subnet.subnetproyfinal2.id]
##  security_groups    = [aws_security_group.ecs_sg_ProyFinal.id]  ## Se realiza ajuste para el SG del Load Balancer
  security_groups    = [aws_security_group.lb_sg_ProyFinal.id]
  enable_deletion_protection = false
    tags = {
    Environment = "Test Saulo"
  }
}

## Creación de Target Group del Balanceador de Carga en AWS para el Proyecto Final
resource "aws_lb_target_group" "lb-tg-proyfinal" {
  name        = "lb-tg-proyfinal"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpcProyFinal.id
  target_type = "ip"
}

## Creación del Listerner del Balanceador de Carga en AWS para el Proyecto Final
resource "aws_lb_listener" "lstnProyFinal" {
  load_balancer_arn = aws_lb.lb-proyfinal.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg-proyfinal.arn
  }
}
