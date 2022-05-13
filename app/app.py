"""
Rest API that reads from an S3 json object and returns
the json message.
"""

import json

import boto3
from flask import Flask


app = Flask(__name__)

# Make the s3 client global to avoid initiation process every time
# the api is hit.
s3_client = boto3.client('s3')


def get_s3_object(bucket, key):
  """Reads from the s3 bucket json key object and returns
  json message with HTTP status code.
  """

  # using try/except to avoid outputting bucket/key info in
  # error dumps to public.
  try:
    obj = s3_client.get_object(Bucket=bucket, Key=key)
  except Exception:
    return {"error": "Could not load s3 object."}, 500

  try:
    message = json.loads(obj['Body'].read().decode('utf-8'))
  except Exception:
    return {"error": "Could not decode s3 object as json."}, 500

  return message, 200


@app.route('/api/foo')
def foo():
  """Returns JSON message from s3 bucket/key object."""
  with open("config.json", "r") as f:
    config = json.load(f)
    bucket = config["bucket"]
    key = config["key"]
  
  message, status_code = get_s3_object(bucket, key)

  # Flask versions >1.1.0 automatically call jsonify for
  # Python dicts
  return message, status_code


if __name__ == '__main__':
  # This is used when running locally only.
  app.run(host='0.0.0.0', port=8080)
