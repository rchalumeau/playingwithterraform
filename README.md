# SREracha terraform #

## AWS authent ##

This set of manifests uses shared authent to connect to AWS. 

In file ~/.aws/credentials
```
[terraform]
aws_access_key_id=ACCESSKEY
aws_secret_access_key=SECRETKEY
```

Refer to [AWS configuration guide for more details](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html)

## Design notes

- Container running in ECS (Fargate) using Redis from elasticache
- For confidentiality purpose, two subnet levels : one public (hosting ECS), one private (hosting Redis)
- For availability, clustering ECS and Redis on two AZ
- Docker fails after 31 loops, so need a way to test and restart the task on ECS
  -> liveness probe with http://:80?q=whatever (if missing query, returns 400)
- Task listen on port 80 : should implement an ALB, with SSL termination to improve security

![design schema](sr.png)


### On Redis

- Activate automated failover for HA
- Add replica in cluster to ensure integrity of redis
- encryption at rest and in transit for prod readiness
- Automated upgrade for security patch policy
- Security group : ingress dedicated to processing CIDRs (ECS in that case)
