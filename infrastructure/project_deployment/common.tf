data "aws_caller_identity" "current" {}

locals {

  project = "Ambrosia"

  unique_id = ""

  tags = {
    "env"        = var.env,
    "created_by" = "Terraform",
    "project"    = local.project
  }

  region = replace(var.region, "-", "")

  project_prefix = lower(format("%s_%s_%s_%s", local.project, local.region, var.env, local.unique_id))                                                #ambrosia_us-east-1_dev_uniqueid

  s3_policy_source     = templatefile("./policies/bucket_policy.json", { bucket_name = replace(format("%s%s", local.project_prefix, "s3"), "_", "") }) #used in wesbite.tf
  js_source            = templatefile("./html/js/jstemplate.js", { url = "${aws_api_gateway_stage.stage.invoke_url}" })                                #used in backend.tf
  lambda_assume_role   = file("./policies/lambda_assume_role.json")                                                                                    #used in backend.tf
  lambda_inline_policy = file("./policies/lambda_inline_policy.json")                                                                                  #used in backend.tf
  lambda_source        = templatefile("./lambda.py", { dynamodb_table_name = "${aws_dynamodb_table.dynamodb-table.id}" })                              #used in backend.tf

}