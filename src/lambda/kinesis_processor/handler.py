import base64
import json
import os
import time
from typing import Any, Dict

import boto3

s3 = boto3.client("s3")
BUCKET = os.environ.get("BUCKET_NAME", "")


def handler(event: Dict[str, Any], context):
    # Kinesis event structure: Records list with base64-encoded data
    record_count = 0
    outputs = []
    for rec in event.get("Records", []):
        try:
            payload_b64 = rec["kinesis"]["data"]
            payload = base64.b64decode(payload_b64)
            record = payload.decode("utf-8", errors="ignore")
            record_count += 1
            key = f"processed/{int(time.time()*1000)}-{record_count}.json"
            if BUCKET:
                s3.put_object(Bucket=BUCKET, Key=key, Body=json.dumps({"raw": record}))
            outputs.append({"key": key})
        except Exception as e:
            # Let Lambda succeed but log the failure for that record
            print(f"Error processing record: {e}")

    print(json.dumps({"processed": record_count, "outputs": outputs}))
    return {"statusCode": 200, "processed": record_count}
