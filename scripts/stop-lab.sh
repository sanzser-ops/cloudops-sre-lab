#!/usr/bin/env bash
set -euo pipefail

PROFILE="cloudops-lab"
REGION="eu-west-1"
INSTANCE_ID="i-04795f3c98b93b8d1"

STATE=$(aws ec2 describe-instances \
  --profile "$PROFILE" --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].State.Name' \
  --output text)

case "$STATE" in
  stopped)
    echo "La instancia ya está detenida."
    exit 0
    ;;
  running)
    ;;
  *)
    echo "No se puede detener ahora: estado actual '$STATE'."
    echo "Espera a que termine la operación en curso y vuelve a intentarlo."
    exit 1
    ;;
esac

echo "Deteniendo instancia..."
aws ec2 stop-instances \
  --profile "$PROFILE" --region "$REGION" \
  --instance-ids "$INSTANCE_ID" >/dev/null

aws ec2 wait instance-stopped \
  --profile "$PROFILE" --region "$REGION" \
  --instance-ids "$INSTANCE_ID"

echo "Instancia detenida. El almacenamiento y otros recursos pueden seguir generando costes."
