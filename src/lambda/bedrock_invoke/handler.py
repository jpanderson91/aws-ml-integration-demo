import json
import os

import boto3

MODEL_ID = os.environ.get("BEDROCK_MODEL_ID", "amazon.titan-text-lite-v1")
# Bedrock runtime client in us-east-1
bedrock = boto3.client("bedrock-runtime", region_name=os.environ.get("AWS_REGION", "us-east-1"))


def handler(event, context):
    # Support API Gateway HTTP API (payload v2.0). Accept prompt via querystring or JSON body.
    prompt = None
    if isinstance(event, dict):
        qs = event.get("queryStringParameters") or {}
        if isinstance(qs, dict) and "prompt" in qs and qs["prompt"]:
            prompt = qs["prompt"]
        if not prompt and event.get("body"):
            body = event["body"]
            try:
                if event.get("isBase64Encoded"):
                    import base64
                    body = base64.b64decode(body).decode("utf-8", "ignore")
                body = json.loads(body)
                if isinstance(body, dict):
                    prompt = body.get("prompt")
            except Exception:
                # fall back to default prompt on any parsing error
                prompt = prompt or None

    if not prompt:
        prompt = "Say hello in one short sentence."

    # Basic request for Titan Text Lite; adjust if using a different model
    request = {
        "inputText": prompt,
        "textGenerationConfig": {
            "temperature": 0.5,
            "topP": 0.9,
            "maxTokenCount": 128
        }
    }

    resp = bedrock.invoke_model(modelId=MODEL_ID, contentType="application/json", accept="application/json", body=json.dumps(request))
    body = json.loads(resp["body"].read().decode("utf-8"))
    output = body.get("results", [{}])[0].get("outputText", "")
    return {"statusCode": 200, "headers": {"content-type": "application/json"}, "body": json.dumps({"model": MODEL_ID, "prompt": prompt, "output": output})}
