#!/usr/bin/env bash
# Read-only AWS audit for HoopTapes. Every command below only describes or lists; nothing is created, changed or deleted.
# Run it at the end of every session to prove nothing hourly is left running (see docs/cost.md).
# Usage: aws sso login --profile dev && AWS_PROFILE=dev ./scripts/audit-aws.sh
# Optional: REGIONS="us-east-1 us-west-2" to scan more regions.
set -u

REGIONS="${REGIONS:-us-east-1}"

echo "== Who am I"
# Show the account ID and SSO role this session is using.
aws sts get-caller-identity --output table

# Save the account ID for the budgets call below.
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

echo "== Budgets"
# List budgets in this account with their monthly limit.
aws budgets describe-budgets --account-id "$ACCOUNT_ID" --query 'Budgets[].{Name:BudgetName,Limit:BudgetLimit.Amount,Unit:TimeUnit}' --output table

for REGION in $REGIONS; do
  echo "== Hourly-billed resources in $REGION (should be empty at the end of a session)"
  # List NAT gateways that are pending or available (about $33/month each while they exist).
  aws ec2 describe-nat-gateways --region "$REGION" --filter Name=state,Values=pending,available --query 'NatGateways[].{Id:NatGatewayId,State:State,Vpc:VpcId}' --output table
  # List Elastic IPs (billed hourly as public IPv4, even when attached to nothing).
  aws ec2 describe-addresses --region "$REGION" --query 'Addresses[].{Ip:PublicIp,AllocationId:AllocationId,AttachedTo:AssociationId}' --output table
  # List interface VPC endpoints (billed per AZ per hour; gateway endpoints for S3/DynamoDB are free and not listed).
  aws ec2 describe-vpc-endpoints --region "$REGION" --filters Name=vpc-endpoint-type,Values=Interface --query 'VpcEndpoints[].{Id:VpcEndpointId,Service:ServiceName,State:State}' --output table
  # List application and network load balancers.
  aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[].{Name:LoadBalancerName,Type:Type,State:State.Code}' --output table
  # List ECS clusters with how many tasks are running in each.
  aws ecs describe-clusters --region "$REGION" --clusters $(aws ecs list-clusters --region "$REGION" --query 'clusterArns' --output text) --query 'clusters[].{Name:clusterName,Running:runningTasksCount}' --output table 2>/dev/null || echo "(no ECS clusters)"
  # List EKS clusters (about $73/month each while they exist).
  aws eks list-clusters --region "$REGION" --query 'clusters' --output table
  # List running EC2 instances (for example a forgotten k6 load-test runner).
  aws ec2 describe-instances --region "$REGION" --filters Name=instance-state-name,Values=pending,running --query 'Reservations[].Instances[].{Id:InstanceId,Type:InstanceType,State:State.Name}' --output table
done

echo "== Done. Empty tables mean nothing was found. Paste everything above back to Claude."
