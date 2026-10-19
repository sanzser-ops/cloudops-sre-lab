# Incident Troubleshooting Knowledge Base

A practical knowledge base documenting troubleshooting exercises,
failures, root-cause investigations, resolutions, and lessons learned
from the CloudOps & SRE lab.

## Categories

- [AWS IAM permissions](aws/iam-permissions/)
- [AWS EC2 connectivity](aws/ec2-connectivity/)
- [Terraform](aws/terraform/)
- [Linux systemd](linux/systemd/)
- [Linux networking](linux/networking/)
- [Linux permissions](linux/permissions/)
- [Ansible inventory](ansible/inventory/)
- [Ansible SSH connectivity](ansible/ssh-connectivity/)
- [Ansible privilege escalation](ansible/privilege-escalation/)

## Documentation standards

Each incident should record:
- Symptoms and exact error messages
- Environment and relevant versions
- Investigation steps and evidence
- Confirmed root cause or explicitly stated hypothesis
- Resolution and validation
- Prevention and lessons learned

Never commit passwords, private keys, access tokens, or other secrets.

## Incident template

Use [the incident template](templates/incident-template.md)
for new troubleshooting records.
