# Terraform and AWS Lambda with CloudWatch Cron Trigger

This project uses **Terraform** to deploy an **AWS Lambda function** that is triggered every **5 minutes** using a **CloudWatch cron rule**. The project includes all required resources, such as S3 buckets for storing Terraform state and Lambda function code.

---

## Project Overview

This project automates the following:
1. **S3 Buckets**:
   - One S3 bucket for storing Terraform state (used to track resource deployments).
   - Another S3 bucket to store the Lambda function ZIP file.
2. **AWS Lambda Function**:
   - Written in Python (`lambda.py`).
   - Packaged as a ZIP file (`lambda.zip`) and stored in an S3 bucket.
3. **CloudWatch Event Rule**:
   - Configured with a cron schedule to trigger the Lambda function **every 5 minutes**.

---

## Prerequisites

Before you begin, ensure you have the following tools installed and configured:

1. **Terraform**: Infrastructure as Code tool  
   - Download: [Terraform Installation Guide](https://developer.hashicorp.com/terraform/downloads)

2. **AWS CLI**: Command Line Interface for AWS  
   - Install and configure it with your AWS credentials:
     ```bash
     aws configure
     ```
     Provide your:
     - AWS Access Key ID
     - AWS Secret Access Key
     - Default region (e.g., `us-east-2`)

3. **Python 3.x**: To write and package the Lambda function  
   - Download: [Python Installation](https://www.python.org/downloads/)

4. **Zip Utility**: To compress your Python code for Lambda  
   - Most Linux/Mac systems come with `zip` pre-installed. Verify with:
     ```bash
     zip --version
     ```

---

## Project Structure

```plaintext
lambda-terraform-cron/
├── main.tf           # Terraform configuration file
├── lambda.py         # Python code for the Lambda function
├── lambda.zip        # Zipped Lambda function code (generated locally)
└── README.md         # Project documentation

Step-by-Step Instructions

1. Clone the Repository

Start by cloning this project to your local machine:
git clone https://github.com/origa2001/lambda-terraform-cron.git
cd lambda-terraform-cron

2. Write the Lambda Function Code
Edit the lambda.py file with your desired logic. Here’s a sample Lambda function:

import datetime

def lambda_handler(event, context):
    print(f"Lambda function triggered at {datetime.datetime.now()}")
    return {
        "statusCode": 200,
        "body": "Hello from Lambda! Triggered by CloudWatch."
    }
3. Package the Lambda Function

Terraform requires the Lambda code to be in a ZIP file. Run this command to create the ZIP file:
zip lambda.zip lambda.py
4. Initialize Terraform
Run the following command to initialize Terraform:

terraform init

This will:

Download the required providers (e.g., AWS).
Set up the Terraform backend (if configured).

5. Review the Terraform Plan
Run the following command to preview the resources Terraform will create:

terraform plan

Terraform will display a list of resources to be created:

Two S3 buckets (one for Terraform state, one for Lambda code).
Lambda function.
CloudWatch Event Rule.

6. Deploy the Infrastructure
Apply the Terraform configuration to create the resources:

terraform apply

Type yes when prompted to confirm

7. Verify the Deployment in AWS
After deployment, verify the resources in your AWS account:

S3 Buckets:

Go to the S3 console.
Verify:
The Terraform state bucket contains the terraform.tfstate file.
The Lambda code bucket contains lambda.zip.

Lambda Function:

Go to the AWS Lambda Console.
Verify the function cron_trigger_lambda exists.
CloudWatch Events:

Go to CloudWatch > Rules.
Verify the rule lambda_cron_trigger is configured with a 5-minute cron schedule.
Test the Lambda:

In the Lambda Console, click on Test to invoke the function manually.
Check CloudWatch Logs for outputs.

Common Issues
BucketAlreadyExists:

Use a unique S3 bucket name since bucket names are globally unique.
Access Denied:

Verify your AWS credentials are correct using aws configure.
Lambda Not Triggering:

Check the CloudWatch Rule configuration and CloudWatch Logs for errors.

Notes
Replace all bucket names in main.tf with unique names.
The cron expression cron(0/5 * * * ? *) means every 5 minutes.
Modify the Lambda function logic in lambda.py as needed.

Conclusion
This project automates AWS resource creation using Terraform and deploys a Lambda function triggered every 5 minutes. It’s a great example of combining Infrastructure as Code (IaC) with serverless compute.


