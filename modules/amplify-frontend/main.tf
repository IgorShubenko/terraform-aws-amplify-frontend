resource "aws_amplify_app" "amplify-app" {
  name                 = var.name
  repository           = var.repository
  access_token         = data.aws_secretsmanager_secret_version.current.secret_string
  iam_service_role_arn = aws_iam_role.default.arn

  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }
}

resource "aws_amplify_branch" "amplify_branch" {
  for_each    = { for branch in var.branches : branch.name => branch }
  app_id      = aws_amplify_app.amplify-app.id
  branch_name = each.value.name

  framework = var.app_framework
  stage     = each.value.stage
}

resource "aws_amplify_webhook" "amplify_webhook" {
  for_each    = { for branch in var.branches : branch.name => branch }
  app_id      = aws_amplify_app.amplify-app.id
  branch_name = aws_amplify_branch.amplify_branch[each.value.name].branch_name
  description = "Trigger branch ${each.value.name}"
}

data "aws_secretsmanager_secret" "access_token" {
  name = var.access_token_name
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.access_token.id
}

data "aws_iam_policy_document" "assume_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["amplify.${var.aws_region}.amazonaws.com", "amplify.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  name                = "${var.name}-service-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmplifyBackendDeployFullAccess"]
}
