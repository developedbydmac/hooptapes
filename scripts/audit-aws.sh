#!/usr/bin/env bash
# Read-only AWS audit for HoopTapes. Every command below only describes or lists; nothing is created, changed or deleted.
# Usage: aws sso login --profile hooptapes && AWS_PROFILE=hooptapes ./scripts/audit-aws.sh
# Optional: REGIONS="us-east-1 us-east-2" to choose which regions to scan for running resources.
set -u

REGIONS="${REGIONS:-us-east-1 us-east-2}"

echo "== Who am I"
# Show the account ID and SSO role this session is using.
aws sts get-caller-identity --output table

# Save the account ID for the budgets call below.
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

echo "== AWS Organization"
# Show the organization this account belongs to (errors with AWSOrganizationsNotInUseException if there is none).
aws organizations describe-organization --query 'Organization.{Id:Id,ManagementAccount:MasterAccountId,FeatureSet:FeatureSet}' --output table

echo "== Member accounts"
# List every account in the organization with its status (only works from the management account).
aws organizations list-accounts --query 'Accounts[].{Name:Name,Id:Id,Email:Email,Status:Status}' --output table

echo "== Budgets"
# List budgets in this account with their monthly limit.
aws budgets describe-budgets --account-id "$ACCOUNT_ID" --query 'Budgets[].{Name:BudgetName,Limit:BudgetLimit.Amount,Unit:TimeUnit}' --output table

echo "== Cost Anomaly Detection"
# List cost anomaly monitors (v2 wants one turned on).
aws ce get-anomaly-monitors --query 'AnomalyMonitors[].{Name:MonitorName,Type:MonitorType}' --output table

echo "== Cost allocation tags"
# List user-defined cost allocation tags and whether each is Active (v2 wants project and env).
aws ce list-cost-allocation-tags --type UserDefined --query 'CostAllocationTags[].{Key:TagKey,Status:Status}' --output table

for REGION in $REGIONS; do
  echo "== Running resources in $REGION"
  # List EKS clusters (each one costs about $73/month while it exists).
  aws eks list-clusters --region "$REGION" --query 'clusters' --output table
  # List NAT gateways that are pending or available (each one costs about $33/month while it exists).
  aws ec2 describe-nat-gateways --region "$REGION" --filter Name=state,Values=pending,available --query 'NatGateways[].{Id:NatGatewayId,State:State,Vpc:VpcId}' --output table
  # List RDS database instances and their status.
  aws rds describe-db-instances --region "$REGION" --query 'DBInstances[].{Id:DBInstanceIdentifier,Class:DBInstanceClass,Status:DBInstanceStatus}' --output table
  # List application and network load balancers.
  aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[].{Name:LoadBalancerName,Type:Type,State:State.Code}' --output table
  # List classic load balancers (older type, still billed).
  aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[].LoadBalancerName' --output table
  # List Elastic IPs (each one is billed hourly, even when attached to nothing).
  aws ec2 describe-addresses --region "$REGION" --query 'Addresses[].{Ip:PublicIp,AllocationId:AllocationId,AttachedTo:AssociationId}' --output table
done

echo "== Done. Empty tables mean nothing was found. Paste everything above back to Claude."
