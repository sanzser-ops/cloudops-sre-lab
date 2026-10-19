#!/usr/bin/env bash
set -euo pipefail

PROFILE="cloudops-lab"
REGION="eu-west-1"
INSTANCE_ID="i-04795f3c98b93b8d1"

echo "Comprobando estado de EC2..."
STATE=$(aws ec2 describe-instances \
  --profile "$PROFILE" --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].State.Name' \
  --output text)

case "$STATE" in
  stopped)
    echo "Arrancando instancia..."
    aws ec2 start-instances \
      --profile "$PROFILE" --region "$REGION" \
      --instance-ids "$INSTANCE_ID" >/dev/null
    ;;
  running)
    echo "La instancia ya está arrancada."
    ;;
  *)
    echo "Estado actual: $STATE. Esperando a que esté disponible..."
    ;;
esac

aws ec2 wait instance-running \
  --profile "$PROFILE" --region "$REGION" \
  --instance-ids "$INSTANCE_ID"

IP=$(aws ec2 describe-instances \
  --profile "$PROFILE" --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Instancia arrancada."
echo "IP pública: $IP"
echo "Conecta con: ./scripts/connect-lab.sh"
