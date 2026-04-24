# T1537 – Transfer Data to Cloud Account | Assessment

## MCQ 1
Attackers prefer T1537 cloud transfer for exfiltration because:
A) Cloud transfers are faster  B) Traffic to S3/GCS/Azure Blob is allowed by most firewalls and blends with legitimate cloud usage  ✅
C) Cloud storage is free  D) It bypasses all authentication

## MCQ 2
`aws sts get-caller-identity` is run after finding AWS keys to:
A) List all AWS services  B) Identify the privilege level and account of the discovered keys before proceeding  ✅
C) Create new AWS credentials  D) Delete CloudTrail logs

## MCQ 3
AWS CloudTrail would log T1537 exfiltration under which event:
A) `GetObject`  B) `PutObject` (when attacker uploads to their bucket) + source IP matching compromised host  ✅
C) `ListBuckets` only  D) `CreateBucket`

## Fill 1
AWS CLI command to sync an entire directory to an S3 bucket:
**Answer:** `aws s3 sync <local_dir> s3://<bucket>/`

## Fill 2
AWS service that logs all API calls (critical for detecting T1537):
**Answer:** `AWS CloudTrail`
