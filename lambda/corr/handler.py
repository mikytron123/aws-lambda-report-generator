import polars as pl
import polars.selectors as cs
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
    print("corr")
    print(event)
    s3_client = boto3.client("s3")
    bucket: str = event["input"]["bucket"]
    key: str = event["input"]["key"]
    df = read_from_s3(s3_client, bucket, key)
    numeric_df = df.select(cs.numeric())
    corr_df = numeric_df.corr().with_columns(
        pl.Series(name="cols", values=numeric_df.columns)
    )
    cols_order = ["cols"] + numeric_df.columns
    corr_df = corr_df[cols_order]
    
    write_to_s3(s3_client, corr_df, "output", "corr.pq")
    return {"func":"corr","bucket":"output","key":"corr.pq"}
