# T1030 – Data Transfer Size Limits | Assessment

## MCQ 1
Chunked exfiltration (T1030) evades which type of DLP control?
A) Content inspection  B) Volume-based DLP rules that block single transfers above a size threshold  ✅
C) Encrypted traffic inspection  D) User behavior analytics

## MCQ 2
`split -b 5000 file /tmp/chunk_` splits a file into:
A) 5000 equal pieces  B) Pieces of 5000 bytes each, named chunk_aa, chunk_ab, etc.  ✅
C) 5 chunks of 1000 bytes  D) 5000 line chunks

## MCQ 3
Adding sleep/delay between chunks helps evade:
A) Content-based DLP  B) Rate-based anomaly detection that alerts on high-volume outbound traffic bursts  ✅
C) Firewall rules  D) Antivirus scanning

## Fill 1
`split` flag to split a file into pieces of 1KB each:
**Answer:** `-b 1000` (or `-b 1k`)

## Fill 2
`cat chunk_aa chunk_ab chunk_ac > reassembled.txt` — this can also be written as:
**Answer:** `cat chunk_a* > reassembled.txt`
