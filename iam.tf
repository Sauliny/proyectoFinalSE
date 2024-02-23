############################################
## Archivo de configuración de IAM Policy ##
############################################

# Se crea IAM Policy Global
data "aws_iam_policy_document" "s3_iam_policy_ProyFinal" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cf-s3-proyfinal.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.OAI_ProyFinal.iam_arn]
    }
  }
}

# Se crea IAM Policy para Bucket
resource "aws_s3_bucket_policy" "s3_bucket_policy_ProyFinal" {
  bucket = aws_s3_bucket.cf-s3-proyfinal.id
  policy = data.aws_iam_policy_document.s3_iam_policy_ProyFinal.json
}

# Se crea aws_iam_role_policy

resource "aws_iam_role_policy" "ecs_iam_role_policy" {
  name = "ecs_iam_role_policy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version ="2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}


# Se crea ecs_task_execution_role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "role-name"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# Se crea ecs_task_role
resource "aws_iam_role" "ecs_task_role" {
  name = "role-name-task" 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

# Se crea ecs-task-execution-role-policy-attachment 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Se crea task_s3
resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}