
# https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file
resource "github_repository_file" "codeowners" {
  repository          = local.github_repo.name
  branch              = github_branch_default.default_main_branch.branch
  file                = "CODEOWNERS"
  content             = templatefile("${path.module}/templates/CODEOWNERS", { codeowners = local.codeowners })
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [
      content,
      branch,
      overwrite_on_create
    ]
  }
}


resource "github_repository_file" "extra_files" {
  for_each            = tomap({ for file in var.extra_files : "${element(split("/", file.path), length(split("/", file.path)) - 1)}" => file })
  repository          = local.github_repo.name
  branch              = var.github_default_branch
  file                = each.value.path
  content             = each.value.content
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [
      content,
      branch
    ]
  }
}


resource "github_repository_file" "github_actions" {
  count = var.github_actions == null ? 0 : 1
  repository          = local.github_repo.name
  branch              = var.github_default_branch
  file                = each.value.path
  content             = templatefile(
    "${path.module}/templates/terraform.yaml.tpl",
    {
      github_username   = var.github_actions.username
      github_email      = var.github_actions.email
      github_org        = var.github_actions.org
      terraform_version = var.github_actions.terraform_version
      terraform_api     = var.github_actions.terraform_api
    }
  )
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [
      content,
      branch
    ]
  }
}
