#!/usr/bin/env bash
set -euo pipefail

PROFILE="cloudops-lab"
REGION="eu-west-1"
INSTANCE_ID="i-04795f3c98b93b8d1"
KEY="$HOME/.ssh/cloudops-sre-lab-aws"

STATE=$(aws ec2 describe-instances \
  --profile "$PROFILE" --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].State.Name' \
  --output text)

if [[ "$STATE" != "running" ]]; then
  echo "La instancia no está arrancada (estado: $STATE)."
  echo "Ejecuta primero: ./scripts/start-lab.sh"
  exit 1
fi

IP=$(aws ec2 describe-instances \
  --profile "$PROFILE" --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

if [[ "$IP" == "None" || -z "$IP" ]]; then
  echo "No se ha encontrado una IP pública para la instancia."
  exit 1
fi

if [[ ! -f "$KEY" ]]; then
  echo "No se encuentra la clave SSH: $KEY"
  exit 1
fi

echo "Conectando a ec2-user@$IP..."
exec ssh -i "$KEY" "ec2-user@$IP"
