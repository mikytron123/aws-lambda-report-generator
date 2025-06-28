import polars as pl
import boto3


def read_from_s3(client, bucket: str, key: str) -> pl.DataFrame:
    """ """
    obj = client.get_object(Bucket=bucket, Key=key)
    if key.endswith("parquet") or key.endswith("pq"):
        return pl.read_parquet(obj["Body"])
    elif key.endswith("csv"):
        return pl.read_csv(obj["Body"])
    else:
        raise ValueError(f"unknown file type {key}")


def write_to_s3(client, df: pl.DataFrame, bucket: str, key: str):
    df.write_parquet("/tmp/temp.pq")
    client.upload_file(Filename="/tmp/temp.pq", Bucket=bucket, Key=key)


def lambda_handler(event, context):
    print("version 4")
    print(event)
    s3_client = boto3.client("s3")
    bucket: str = event["input"]["bucket"]
    key: str = event["input"]["key"]
    df = read_from_s3(s3_client, bucket, key)
    stat_df = df.describe()
    write_to_s3(s3_client, stat_df, "output", "stat.pq")
    return {"func":"stat","bucket":"output","key":"stat.pq"}
