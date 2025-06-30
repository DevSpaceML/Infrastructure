import sys
import boto3
from botocore.exceptions import ClientError

#class CloudMonitor:

def nginx_cpu_alarm():
    cw = boto3.client('cloudwatch')

    #Create Metric alarm with actions 
    cw.put_metric_alarm(
        AlarmName='Nginx_Server_Alarm'
        ComparisonOperator='GreaterThanThreshold'
        EvaluationPeriods=1
        MetricName='CPUUtilization'
        NameSpace='AWS/EC2'
        Period=60
        Statistic='Average'
        Threshold=70.0
        ActionsEnabled=True
        AlarmActions=['arn:aws:swf:us-west-2:{CUSTOMER_ACCOUNT}:action/actions/AWS_EC2.InstanceId.Reboot/1.0']
        AlarmDescription='Alarm when sever CPU exceeds 70%'
    )


'''
def manage_instance():
    s3Client = boto3.client('s3')
'''
