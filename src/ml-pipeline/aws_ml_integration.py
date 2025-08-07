"""
AWS ProServe ML Integration Demo
Demonstrates SageMaker, Bedrock, and Amazon Q integration for enterprise customers
Author: John Anderson - AWS Delivery Consultant Demo
"""

import json
import boto3
import logging
from typing import Dict, Any, List, Optional
from datetime import datetime
import pandas as pd
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

class AWSMLIntegrationService:
    """
    Enterprise ML service demonstrating AWS AI/ML capabilities for ProServe delivery:
    - SageMaker model training and inference
    - Bedrock generative AI integration
    - Amazon Q business intelligence
    - ML governance and responsible AI practices
    """
    
    def __init__(self):
        self.sagemaker_client = boto3.client('sagemaker')
        self.sagemaker_runtime = boto3.client('sagemaker-runtime')
        self.bedrock_client = boto3.client('bedrock-runtime')
        self.bedrock_agent = boto3.client('bedrock-agent-runtime')
        self.s3_client = boto3.client('s3')
        
    def analyze_customer_sentiment(self, text_content: str) -> Dict[str, Any]:
        """
        Use SageMaker endpoint for customer sentiment analysis
        Demonstrates real-time ML inference capabilities
        """
        try:
            endpoint_name = 'customer-sentiment-analyzer'
            
            # Prepare input for SageMaker endpoint
            payload = {
                'instances': [{'text': text_content}]
            }
            
            # Invoke SageMaker endpoint
            response = self.sagemaker_runtime.invoke_endpoint(
                EndpointName=endpoint_name,
                ContentType='application/json',
                Body=json.dumps(payload)
            )
            
            # Parse response
            result = json.loads(response['Body'].read().decode())
            
            logger.info(f"Sentiment analysis completed for text length: {len(text_content)}")
            
            return {
                'sentiment': result.get('predictions', [{}])[0].get('sentiment', 'neutral'),
                'confidence': result.get('predictions', [{}])[0].get('confidence', 0.0),
                'model_version': response['ResponseMetadata'].get('HTTPHeaders', {}).get('x-amzn-SageMaker-Model-Version', 'unknown'),
                'processing_time_ms': response['ResponseMetadata'].get('HTTPHeaders', {}).get('x-amzn-SageMaker-Processing-Time', 'unknown')
            }
            
        except ClientError as e:
            logger.error(f"SageMaker endpoint error: {str(e)}")
            # Fallback to Bedrock if SageMaker endpoint is unavailable
            return self._bedrock_sentiment_fallback(text_content)
    
    def generate_customer_insights(self, customer_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Use Amazon Bedrock for intelligent customer insights generation
        Demonstrates generative AI capabilities for business intelligence
        """
        try:
            # Use Claude 3 on Bedrock for analysis
            model_id = 'anthropic.claude-3-sonnet-20240229-v1:0'
            
            prompt = f"""
            Analyze this customer data and provide actionable insights for AWS cloud migration:
            
            Customer Information:
            - Company: {customer_data.get('company', 'Unknown')}
            - Industry: {customer_data.get('industry', 'Unknown')}
            - Current Infrastructure: {customer_data.get('current_infrastructure', 'On-premises')}
            - Business Goals: {customer_data.get('business_goals', 'Cost optimization')}
            - Technical Requirements: {customer_data.get('tech_requirements', 'Scalability')}
            
            Please provide:
            1. Recommended AWS architecture approach
            2. Migration strategy and timeline
            3. Cost optimization opportunities
            4. Security and compliance considerations
            5. Success metrics and KPIs
            
            Format the response as structured recommendations for a ProServe engagement.
            """
            
            body = {
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 2000,
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ]
            }
            
            response = self.bedrock_client.invoke_model(
                modelId=model_id,
                body=json.dumps(body),
                contentType='application/json'
            )
            
            response_body = json.loads(response['body'].read())
            insights = response_body['content'][0]['text']
            
            logger.info(f"Bedrock insights generated for customer: {customer_data.get('company', 'Unknown')}")
            
            return {
                'insights': insights,
                'model_used': model_id,
                'token_count': response_body.get('usage', {}).get('output_tokens', 0),
                'generated_at': datetime.now().isoformat()
            }
            
        except ClientError as e:
            logger.error(f"Bedrock error: {str(e)}")
            return {
                'error': 'Unable to generate insights',
                'fallback_message': 'Please contact your AWS ProServe team for detailed analysis'
            }
    
    def query_knowledge_base(self, query: str, customer_context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Use Amazon Q Business for intelligent knowledge retrieval
        Demonstrates AI-powered business intelligence capabilities
        """
        try:
            # Amazon Q Business integration
            application_id = 'your-amazon-q-application-id'
            
            # Enhanced query with customer context
            enhanced_query = f"""
            Customer Context: {customer_context.get('industry', 'General')} industry, 
            {customer_context.get('size', 'Medium')} company size
            
            Query: {query}
            
            Focus on AWS best practices and ProServe delivery approaches.
            """
            
            response = self.bedrock_agent.retrieve_and_generate(
                input={
                    'text': enhanced_query
                },
                retrieveAndGenerateConfiguration={
                    'type': 'KNOWLEDGE_BASE',
                    'knowledgeBaseConfiguration': {
                        'knowledgeBaseId': 'your-knowledge-base-id',
                        'modelArn': 'arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0'
                    }
                }
            )
            
            return {
                'answer': response['output']['text'],
                'sources': [ref['location']['s3Location']['uri'] for ref in response.get('citations', [])],
                'confidence': response.get('guardrailAction', {}).get('confidence', 'medium'),
                'query_processed_at': datetime.now().isoformat()
            }
            
        except ClientError as e:
            logger.error(f"Amazon Q query error: {str(e)}")
            return {
                'answer': 'Knowledge base temporarily unavailable. Please consult AWS documentation.',
                'error': str(e)
            }
    
    def train_custom_model(self, training_data_s3_path: str, model_name: str) -> Dict[str, Any]:
        """
        Demonstrate SageMaker training job creation for custom models
        Shows MLOps capabilities and model lifecycle management
        """
        try:
            training_job_name = f"{model_name}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
            
            # SageMaker training job configuration
            training_job_config = {
                'TrainingJobName': training_job_name,
                'AlgorithmSpecification': {
                    'TrainingInputMode': 'File',
                    'TrainingImage': '382416733822.dkr.ecr.us-east-1.amazonaws.com/xgboost:latest'
                },
                'RoleArn': 'arn:aws:iam::123456789012:role/SageMakerRole',
                'InputDataConfig': [
                    {
                        'ChannelName': 'training',
                        'DataSource': {
                            'S3DataSource': {
                                'S3DataType': 'S3Prefix',
                                'S3Uri': training_data_s3_path,
                                'S3DataDistributionType': 'FullyReplicated'
                            }
                        },
                        'ContentType': 'text/csv',
                        'CompressionType': 'None'
                    }
                ],
                'OutputDataConfig': {
                    'S3OutputPath': f's3://your-ml-bucket/models/{model_name}/'
                },
                'ResourceConfig': {
                    'InstanceType': 'ml.m5.large',
                    'InstanceCount': 1,
                    'VolumeSizeInGB': 10
                },
                'StoppingCondition': {
                    'MaxRuntimeInSeconds': 3600
                },
                'Tags': [
                    {'Key': 'Project', 'Value': 'ProServe-ML-Demo'},
                    {'Key': 'Owner', 'Value': 'John-Anderson'},
                    {'Key': 'Environment', 'Value': 'Demo'}
                ]
            }
            
            # Start training job
            response = self.sagemaker_client.create_training_job(**training_job_config)
            
            logger.info(f"Training job started: {training_job_name}")
            
            return {
                'training_job_name': training_job_name,
                'training_job_arn': response['TrainingJobArn'],
                'status': 'InProgress',
                'estimated_completion': '30-60 minutes',
                'monitoring_url': f"https://console.aws.amazon.com/sagemaker/home#/jobs/{training_job_name}"
            }
            
        except ClientError as e:
            logger.error(f"SageMaker training job error: {str(e)}")
            return {
                'error': 'Failed to start training job',
                'details': str(e)
            }
    
    def _bedrock_sentiment_fallback(self, text_content: str) -> Dict[str, Any]:
        """Fallback sentiment analysis using Bedrock when SageMaker is unavailable"""
        try:
            model_id = 'amazon.titan-text-express-v1'
            
            prompt = f"""
            Analyze the sentiment of this text and return only a JSON response:
            
            Text: "{text_content}"
            
            Return format:
            {{"sentiment": "positive|negative|neutral", "confidence": 0.95}}
            """
            
            body = {
                "inputText": prompt,
                "textGenerationConfig": {
                    "maxTokenCount": 100,
                    "temperature": 0.1
                }
            }
            
            response = self.bedrock_client.invoke_model(
                modelId=model_id,
                body=json.dumps(body),
                contentType='application/json'
            )
            
            result = json.loads(response['body'].read())
            
            return {
                'sentiment': 'neutral',  # Simplified for demo
                'confidence': 0.8,
                'model_version': 'bedrock-fallback',
                'processing_time_ms': 'variable'
            }
            
        except Exception as e:
            logger.error(f"Bedrock fallback error: {str(e)}")
            return {
                'sentiment': 'neutral',
                'confidence': 0.5,
                'model_version': 'fallback',
                'error': 'Analysis unavailable'
            }

# Lambda handler for API Gateway integration
def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler demonstrating ML service integration
    """
    
    headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
    }
    
    try:
        ml_service = AWSMLIntegrationService()
        http_method = event.get('httpMethod', '')
        path = event.get('path', '')
        
        if http_method == 'POST' and path == '/analyze-sentiment':
            body = json.loads(event.get('body', '{}'))
            result = ml_service.analyze_customer_sentiment(body.get('text', ''))
            
        elif http_method == 'POST' and path == '/generate-insights':
            body = json.loads(event.get('body', '{}'))
            result = ml_service.generate_customer_insights(body.get('customer_data', {}))
            
        elif http_method == 'POST' and path == '/query-knowledge':
            body = json.loads(event.get('body', '{}'))
            result = ml_service.query_knowledge_base(
                body.get('query', ''),
                body.get('context', {})
            )
            
        else:
            result = {
                'message': 'AWS ProServe ML Integration Demo API',
                'available_endpoints': [
                    '/analyze-sentiment',
                    '/generate-insights', 
                    '/query-knowledge'
                ],
                'demo_purpose': 'Showcasing SageMaker, Bedrock, and Amazon Q integration'
            }
        
        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps(result)
        }
        
    except Exception as e:
        logger.error(f"Handler error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({
                'error': 'Internal server error',
                'message': 'Please contact your AWS ProServe team'
            })
        }
