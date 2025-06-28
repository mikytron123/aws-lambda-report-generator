resource "aws_s3_bucket" "output_storage" {
    bucket = "output"
  
}

resource "aws_s3_bucket" "input_storage" {
    bucket = "input"
  
}

resource "aws_s3_bucket" "lambda_storage" {
    bucket = "lambda"
}

resource "aws_s3_object" "input_data" {
    bucket = aws_s3_bucket.input_storage.bucket
    key="data.pq"
    source = "data.pq"
}

resource "aws_iam_role" "lambda_s3_role" {
    name = "lambda_role"

    assume_role_policy = file("lambda_trust_policy.json")
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
    role = aws_iam_role.lambda_s3_role.name

    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  
}

resource "aws_s3_object" "lambda_zip" {
    
    
    bucket = aws_s3_bucket.lambda_storage.bucket
    count = length(var.lambda_objs)

    key = var.lambda_objs[count.index].s3key
    source = var.lambda_objs[count.index].path
    etag = filemd5(var.lambda_objs[count.index].path)
}

resource "aws_lambda_function" "lambda_funcs" {
    count=length(var.lambda_objs)
    s3_bucket = aws_s3_bucket.lambda_storage.bucket
    s3_key = var.lambda_objs[count.index].s3key
    source_code_hash = filebase64sha256(var.lambda_objs[count.index].path)
    function_name = var.lambda_objs[count.index].name
    role          = aws_iam_role.lambda_s3_role.arn
    handler       = "handler.lambda_handler"
    runtime = "python3.12"
    timeout = 60
    publish = true
}   

resource "aws_sfn_state_machine" "sfn_state_machine" {
    name = "report_machine"
    role_arn = aws_iam_role.lambda_s3_role.arn
    definition = file("step_definition.json")
}

# resource "aws_s3_object" "stat_lambda_zip" {
#     bucket = aws_s3_bucket.lambda_storage.bucket
#     key = "stat/lambda_function.zip"
#     source = var.stat_lambda_path
#     etag = filemd5(var.stat_lambda_path)
# }

# resource "aws_s3_object" "corr_lambda_zip" {
#     bucket = aws_s3_bucket.lambda_storage.bucket
#     key = "corr/lambda_function.zip"
#     source = var.corr_lambda_path
#     etag = filemd5(var.corr_lambda_path)
# }

# resource "aws_lambda_function" "stat_lambda" {
#   # If the file is not in the current working directory you will need to include a
#   # path.module in the filename.
#   s3_bucket = aws_s3_bucket.lambda_storage.bucket
#   s3_key = aws_s3_object.stat_lambda_zip.key

#   source_code_hash = filebase64sha256(var.stat_lambda_path)
  
#   function_name = "stat"
#   role          = aws_iam_role.lambda_s3_role.arn
#   handler       = "handler.lambda_handler"

#   runtime = "python3.12"
#   publish = true

# }

# resource "aws_lambda_function" "corr_lambda" {
#   # If the file is not in the current working directory you will need to include a
#   # path.module in the filename.
#   s3_bucket = aws_s3_bucket.lambda_storage.bucket
#   s3_key = aws_s3_object.corr_lambda_zip.key

#   source_code_hash = filebase64sha256(var.corr_lambda_path)
  
#   function_name = "stat"
#   role          = aws_iam_role.lambda_s3_role.arn
#   handler       = "handler.lambda_handler"

#   runtime = "python3.12"
#   publish = true

# }

