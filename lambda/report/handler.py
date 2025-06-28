import botocore.client
import polars as pl
import boto3
import botocore
from jinja2 import Environment, FileSystemLoader, select_autoescape
from great_tables import GT


def read_from_s3(client, bucket: str, key: str) -> pl.DataFrame:
    """ """
    obj = client.get_object(Bucket=bucket, Key=key)
    if key.endswith("parquet") or key.endswith("pq"):
        return pl.read_parquet(obj["Body"])
    elif key.endswith("csv"):
        return pl.read_csv(obj["Body"])
    else:
        raise ValueError(f"unknown file type {key}")


def write_string_to_s3(client, html: str, bucket: str, key: str):
    client.put_object(Bucket=bucket, Key=key, Body=html, ContentType="text/html")


def lambda_handler(event, context):
    print(event)
    s3_client = boto3.client("s3")
    template_inputs = {}
    for ev in event["input"]:
        print("-------")
        print(ev)
        payload = ev["Payload"]
        bucket = payload["bucket"]
        key = payload["key"]
        print(payload)
        df = GT(read_from_s3(s3_client,bucket,key))

        if payload["func"]=="corr":
            template_inputs["corr_df"] = df
        elif payload["func"]=="stat":
            template_inputs["stat_df"] = df

    # bucket: str = event["input"]["bucket"]
    # key: str = event["input"]["key"]
    env = Environment(
        loader=FileSystemLoader("templates"), autoescape=select_autoescape()
    )

    template = env.get_template("template.html")

    render_str = template.render(**template_inputs)
    write_string_to_s3(s3_client, render_str, "output", "report.html")
