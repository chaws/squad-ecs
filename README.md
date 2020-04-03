# Squad on AWS ECS

Before anything else, you need to export the following environment variables:

```
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION="us-east-1"
export TF_VAR_account_number=""
```

Now you're ready to deploy SQUAD on ECS:

```
./terraform apply
```

This will create the following (diagram to come):

ECS
* one cluster
* one service
* one task definition
  * one container definition

Support services
* one role for task execution
  * one role policy
  * one role policy attachement
* one application load balancer
  * one listener
  * one target group
* one vpc
* two subnets: one private and one public (internet access)
* one internet gateway
* one NAT gateway
* one log group on cloudwatch to store containers logs (stdout)
* two security groups: one for the application load balancer and one for the containers 
* one auto-scale target
  * two auto-scale policies: one for scaling-up and one for scaling-down
  * two cloudwatch alarms to triger auto-scaling: one to detect high CPU usage and one to detect CPU idleness

## Accessing

At the end of the execution, terraform should output the application load balancer DNS url, you can get that and append port `8000` and test in any browser. The SQUAD home page should be rendered!
