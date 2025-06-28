variable "lambda_objs" {
  type = list(object({
    path = string
    s3key = string
    name = string
  }))
  default = [ {
    path = "lambda/stat/pkg.zip"
    s3key = "stat/lambda_function.zip"
    name = "stat"
  },{
    path = "lambda/corr/pkg.zip"
    s3key = "corr/lambda_function.zip"
    name = "corr"
  },{
    path = "lambda/report/pkg.zip"
    s3key = "report/lambda_function.zip"
    name = "report"
  } ]
}