# aws-ml-integration-demo - Quick Start Guide

> ⚡ **Deploy working AWS data-pipeline in 10-12 minutes**

## 🎯 **What You'll Get**

After following this guide, you'll have:
- ✅ **Live data-pipeline** processing real data
- ✅ **Working dashboards** with metrics and monitoring
- ✅ **Cost-optimized setup** (~$20/month)
- ✅ **Portfolio-ready demonstration** with screenshots

---

## 📋 **Prerequisites (2 minutes)**

### Required Tools
```powershell
# Verify installations
aws --version          # AWS CLI v2 required
terraform --version    # Terraform 1.5+ required
python --version       # Python 3.8+ required
git --version          # Git for cloning
```

### AWS Configuration
```powershell
# Configure AWS credentials (choose one method)

# Method 1: AWS SSO (Recommended)
aws configure sso --profile aws-ml-integration-demo

# Method 2: AWS CLI configure
aws configure --profile aws-ml-integration-demo

# Verify access
aws sts get-caller-identity --profile aws-ml-integration-demo
```

---

## 🚀 **Deploy Infrastructure (10-12 minutes)**

### Step 1: Clone and Setup
```powershell
# Clone repository
git clone https://github.com/jpanderson91/aws-ml-integration-demo.git
cd aws-ml-integration-demo

# Set AWS profile for session
$env:AWS_PROFILE = "aws-ml-integration-demo"
```

### Step 2: Deploy with Terraform
```powershell
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review planned changes (optional)
terraform plan

# Deploy infrastructure
terraform apply -auto-approve
```

**Expected Output (example):**
```
Apply complete! Resources: 10+ added, 0 changed, 0 destroyed.

Outputs:
dashboard_urls = {
  "cloudwatch_dashboard" = "https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=aws-ml-integration-demo-dev-overview"
}
sagemaker_notebook = {
  name, arn, instance_type, url, console_overview
}
```

### Step 3: Verify Deployment
```powershell
# Check Kinesis & Lambda resources
terraform output stream_and_lambda

# Check SageMaker notebook details
terraform output sagemaker_notebook

# View all resources
terraform output

# Open SageMaker Notebook instance (console link from output)
terraform output -json sagemaker_notebook | jq -r .console_overview
```

---

## 🧪 **Test the System (3 minutes)**

### Generate Test Data
```powershell
# Send test records to Kinesis
cd ../testing/integration
$stream = (cd ../../terraform; terraform output -raw stream_and_lambda | ConvertFrom-Json).stream_name
./send_records.ps1 -StreamName $stream -Count 10
```

**Expected Results:**
```
✅ Kinesis shows records and Lambda shows invocations in CloudWatch
✅ S3 bucket receives processed objects
✅ Bedrock API returns a JSON response with generated text
✅ Notebook can import boto3 and list buckets
```

### View Live Dashboards
```powershell
# Get dashboard URLs
cd ../terraform
terraform output dashboard_urls

# Optional: curl Bedrock API example endpoint printed in outputs
$bedrock = terraform output -json bedrock_demo | ConvertFrom-Json
$url = "$($bedrock.api_endpoint)/bedrock?prompt=hello"
Write-Host "Invoke: $url"  
```

### Verify SageMaker Notebook (optional but recommended)
1. From the SageMaker console link in `terraform output sagemaker_notebook`, open the notebook instance and click "Open JupyterLab".
2. Create a new Python 3 notebook and run a quick sanity cell:
  - import boto3, os; print(boto3.Session().region_name); print([b['Name'] for b in boto3.client('s3').list_buckets()['Buckets'] if 'ml-integration-demo' in b['Name']])
3. Take the screenshots listed in README under "SageMaker Notebook Demo".

---

## 📊 **Portfolio Demonstration**

### Screenshots for Portfolio
1. Kinesis Stream Monitoring: IncomingRecords and IteratorAge
2. Lambda Metrics: Invocations, Errors, Duration (p99)
3. SageMaker Notebook: JupyterLab + sanity cell output

### Key Demonstration Points
- **Working Infrastructure**: Live metrics with zero errors
- **Cost Optimization**: $20/month operational cost
- **Professional Architecture**: Event-driven pipeline, serverless components
- **Security Best Practices**: S3 encryption, IAM least-privilege, logging

---

## 🔧 **Troubleshooting**

### Common Issues

**Issue**: `terraform apply` fails with permissions error
```powershell
# Solution: Verify AWS credentials
aws sts get-caller-identity --profile aws-ml-integration-demo

# Check required permissions
aws sts get-caller-identity --profile aws-ml-integration-demo
```

**Issue**: No data appearing in dashboards
```powershell
# Solution: Generate test data
cd testing
python test_data-pipeline.py

# Wait 2-3 minutes for data to appear
```

**Issue**: High costs in AWS
```powershell
# Solution: Check resource usage
aws ce get-cost-and-usage --time-period Start=2025-08-01,End=2025-08-31 --granularity DAILY --metrics UnblendedCost --profile aws-ml-integration-demo

# Clean up if needed
terraform destroy -auto-approve
```

### Get Help
- **Documentation**: See `/docs` directory
- **Issue Tracking**: Check `docs/ISSUE_TRACKING.md`
- **Architecture**: Review `docs/ARCHITECTURE.md`

---

## 🧹 **Cleanup (When Done)**

### Destroy Infrastructure
```powershell
# Navigate to terraform directory
cd terraform

# Destroy all resources
terraform destroy -auto-approve

# Verify cleanup
terraform state list

# Optional: spot-check via AWS CLI (should not show demo resources)
# aws kinesis list-streams --profile aws-ml-integration-demo
# aws sagemaker list-notebook-instances --profile aws-ml-integration-demo
# aws apigatewayv2 get-apis --profile aws-ml-integration-demo
```

**Expected Output:**
```
Destroy complete! Resources: all Terraform-managed resources destroyed.
```

---

## 🎯 **Success Checklist**

After completing this guide, you should have:

- [ ] ✅ Infrastructure deployed successfully
- [ ] ✅ Test data flowing through system
- [ ] ✅ Dashboards showing live metrics
- [ ] ✅ Screenshots taken for portfolio
- [ ] ✅ Understanding of architecture
- [ ] ✅ Cleanup completed (if demo is done)

---

## 🚀 **Next Steps**

### For Portfolio
1. **Take Screenshots**: Capture working dashboards
2. **Document Experience**: Note any customizations made
3. **Update Resume**: Add data-pipeline and AWS services to skills

### For Enterprise Demo
1. **Deploy Enterprise Version**: See `enterprise-demo/` directory
2. **Enable Advanced Features**: Review enterprise configuration
3. **Cost Analysis**: Compare basic vs enterprise costs

### For Learning
1. **Explore Code**: Review `/src` directory implementation
2. **Study Terraform**: Examine infrastructure patterns
3. **Customize Features**: Modify and redeploy

---

**⏱️ Total Time**: 10-12 minutes
**💰 Cost**: ~$20/month
**🎯 Result**: Production-ready data-pipeline with live dashboards

**Perfect for technical interviews, portfolio demonstrations, and AWS skills validation!**
