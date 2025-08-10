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
git clone {{REPO_URL}}
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

**Expected Output:**
```
Apply complete! Resources: {{RESOURCE_COUNT}} added, 0 changed, 0 destroyed.

Outputs:
dashboard_urls = {
  "{{DASHBOARD_1}}" = "https://{{REGION}}.console.aws.amazon.com/cloudwatch/home#dashboards:name={{DASHBOARD_NAME_1}}"
  "{{DASHBOARD_2}}" = "https://{{REGION}}.console.aws.amazon.com/cloudwatch/home#dashboards:name={{DASHBOARD_NAME_2}}"
}
```

### Step 3: Verify Deployment
```powershell
# Check Kinesis Analytics status
{{VERIFICATION_COMMAND_1}}

# Check Lambda status
{{VERIFICATION_COMMAND_2}}

# View all resources
terraform output

# Open SageMaker Notebook instance (console link from output)
terraform output -json sagemaker_notebook | jq -r .console_overview
```

---

## 🧪 **Test the System (3 minutes)**

### Generate Test Data
```powershell
# Navigate to testing directory
cd ../testing

# Install Python dependencies (if needed)
pip install -r requirements.txt

# Run end-to-end test
python test_data-pipeline.py
```

**Expected Results:**
```
✅ {{TEST_RESULT_1}}
✅ {{TEST_RESULT_2}}
✅ {{TEST_RESULT_3}}
✅ All tests passed - System is working correctly!
```

### View Live Dashboards
```powershell
# Get dashboard URLs
cd ../terraform
terraform output dashboard_urls

# Open dashboards in browser (copy URLs from output)
```

### Verify SageMaker Notebook (optional but recommended)
1. From the SageMaker console link in `terraform output sagemaker_notebook`, open the notebook instance and click "Open JupyterLab".
2. Create a new Python 3 notebook and run a quick sanity cell:
  - import boto3, os; print(boto3.Session().region_name); print([b['Name'] for b in boto3.client('s3').list_buckets()['Buckets'] if 'ml-integration-demo' in b['Name']])
3. Take the screenshots listed in README under "SageMaker Notebook Demo".

---

## 📊 **Portfolio Demonstration**

### Screenshots for Portfolio
1. **Main Dashboard**: Shows {{DASHBOARD_1_DESCRIPTION}}
2. **Metrics Dashboard**: Shows {{DASHBOARD_2_DESCRIPTION}}
3. **Cost Dashboard**: Shows resource costs and optimization

### Key Demonstration Points
- **Working Infrastructure**: Live metrics with zero errors
- **Cost Optimization**: $20/month operational cost
- **Professional Architecture**: {{ARCHITECTURE_HIGHLIGHTS}}
- **Security Best Practices**: {{SECURITY_HIGHLIGHTS}}

---

## 🔧 **Troubleshooting**

### Common Issues

**Issue**: `terraform apply` fails with permissions error
```powershell
# Solution: Verify AWS credentials
aws sts get-caller-identity --profile aws-ml-integration-demo

# Check required permissions
{{PERMISSION_CHECK_COMMAND}}
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
{{COST_CHECK_COMMAND}}

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
{{CLEANUP_VERIFICATION}}
```

**Expected Output:**
```
Destroy complete! Resources: {{RESOURCE_COUNT}} destroyed.
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
