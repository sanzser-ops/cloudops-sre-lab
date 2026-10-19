# Incident: IAM permissions denied when creating an EC2 instance with Terraform

## 1. Summary

- **Incident ID:** AWS-IAM-001
- **Date:** 2026-10-19
- **Category:** AWS IAM / EC2 / Terraform
- **Severity:** Medium
- **Status:** Resolved

Terraform could provision the VPC and supporting network resources, but creating an EC2 instance initially failed because the IAM principal lacked the required authorization for parts of the `ec2:RunInstances` operation.

## 2. Environment

- **Operating system:** Red Hat Enterprise Linux
- **Cloud provider:** AWS
- **Region:** eu-west-1
- **Infrastructure as Code:** Terraform
- **AWS provider:** hashicorp/aws 5.100.0
- **AWS CLI profile:** cloudops-lab
- **IAM policy:** CloudOpsSRELabProvisioning
- **Affected components:** EC2, IAM, EBS, Terraform

## 3. Symptoms and error messages

During `terraform apply`, EC2 instance creation failed with IAM authorization errors involving `ec2:RunInstances`.

Two authorization failures were encountered:

1. Authorization was denied for `ec2:RunInstances` on the EC2 key pair resource.
2. Authorization was denied for `ec2:RunInstances` on the EBS volume resource.

The exact full AWS error messages were not retained in this report.

## 4. Investigation

### Step 1: Run Terraform

Commands:

```bash
terraform plan
terraform apply
```

Terraform attempted to create the EC2 instance but failed because the IAM policy did not authorize all the resources involved in the launch operation.

### Step 2: Review IAM permissions

The custom IAM policy `CloudOpsSRELabProvisioning` was reviewed.

The initial `ec2:RunInstances` permissions used a project-tag request condition too broadly across the resources involved in the launch operation.

After correcting the first authorization failure, a second error identified missing authorization for the EBS volume resource.

### Step 3: Separate permissions by resource type

The `ec2:RunInstances` permissions were separated into scoped statements covering:

- Supporting resources, including the AMI, subnet, network interface, security group, and key pair.
- The EC2 instance resource, with the required project-tag condition.
- The EBS volume resource, with a regional restriction.

## 5. Root cause

The initial IAM policy did not authorize every resource required by the `ec2:RunInstances` operation.

The project-tag condition was applied too broadly to supporting resources, and the EBS volume also required explicit authorization.

Separating the permissions into appropriately scoped statements resolved the observed authorization failures.

## 6. Resolution

The custom IAM policy `CloudOpsSRELabProvisioning` was updated with separate statements:

- `LaunchLabSupportingResources`
- `LaunchTaggedLabInstance`
- `LaunchLabVolumes`

The policy retained the regional restriction to `eu-west-1`. The EC2 instance statement requires the project tag `Project=cloudops-sre-lab`.

The issue was resolved without granting broad administrator permissions.

## 7. Validation

Terraform was run again after the IAM policy changes.

Result:

`Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`

The EC2 instance was created successfully.

## 8. Prevention and lessons learned

- Review the AWS authorization requirements for multi-resource operations such as `ec2:RunInstances`.
- Do not assume that permission on the EC2 instance resource alone is enough.
- Apply request-tag conditions only where appropriate for the resource types and operation.
- Keep IAM permissions scoped to the resources and regions required.
- Re-run Terraform and validate the result after changing IAM permissions.
- Record complete error messages in future incidents to improve troubleshooting accuracy.
- Never commit credentials, access tokens, or private keys to Git.

## 9. References

- [AWS EC2 API: RunInstances](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstances.html)
- [IAM actions, resources, and condition keys for Amazon EC2](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2.html)
