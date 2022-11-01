data "aws_caller_identity" "current" {
}

resource "aws_iam_role" "instance_role" {
  name = lower(var.project_name)

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "role_policy" {
  name = "${lower(var.project_name)}_ssm_get_parameter_policy"
  role = aws_iam_role.instance_role.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter*",
            "Resource": "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/nva-quest-01/*"
        },
        {
            "Effect": "Allow",
            "Action": "kms:Decrypt",
            "Resource": "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/d506b296-d1b0-4417-a84d-906cee0a0654"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = lower(var.project_name)
  role = aws_iam_role.instance_role.name
}
