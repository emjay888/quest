Github URL: https://github.com/ferzconnect01/quest
1. Public cloud & index page (contains the secret word) -
`http://nva-quest-01-1043017906.us-east-1.elb.amazonaws.com/`
2. Docker check -
`http://nva-quest-01-1043017906.us-east-1.elb.amazonaws.com/docker`
3. Secret Word check -
`http://nva-quest-01-1043017906.us-east-1.elb.amazonaws.com/secret_word`
4. Load Balancer check  -
`http://nva-quest-01-1043017906.us-east-1.elb.amazonaws.com/loadbalanced`


# Overview of my solution for this quest.

### 1. Terraform:
Configuration files in this directory creates EC2 instances, Target Group with an ALB and bootstraps our application deployment.  

Prerequisites already set up and used for this deployments are:
VPC and public subnets

ec2.tf: This configuration file Imports the latest AMI for Amazon Linux 2 x86_64.
Creates EC2 instances leveraging the Terraform AWS source modules while bootstrapping our application deployment. We also create a Security group for our application instances.

key.tf: This configuration file creates a secure private key and stores this in AWS SSM parameter store.
We register the key pair's public key with AWS to allow logging-in to our EC2 instances via SSH.

iam.tf: This configuration file creates an IAM role with AmazonSSMManagedInstanceCore permission policy and also the Role policy to allow EC2 retrieve our "SECRET_WORD" SSM parameter .
AmazonSSMManagedInstanceCore: Enables AWS Systems Manager service core functionality, thereby allowing connection to our EC2 instance using Session Manager.

alb.tf: This configuration file creates AWS Application LoadBalancer, ALB Listener for web traffic request on port 80, ALB Target Group and Target Group attachment for our EC2 Instances.

backend.tf: Encrypts and stores the Terraform state as the given key in the provided S3 bucket. We also enabled Terraform state locking by setting the dynamodb_table field.

provider.tf: Declare required providers to allow Terraform install and use them.

variables.tf: Declare input variables.

outputs.tf: Declare output variables.

locals.tf: Declare local variables.

- In order to add TLS (https) I'd need a registered domain (I don't have this at this moment) - I've gone ahead to add the configuration files needed to add an ACM generated SSL/TLS cert to an ALB.
Prerequisites:
Registered domain and Hosted Zone in AWS Route53:

route53.tf: Imports details about a Route 53 Hosted Zone.
Adds Amazon Route53 alias records pointing to our ALB resource.

acm.tf: We request a DNS validated certificate, deploy the required validation records and wait for validation to complete. Upon completion we will be issued an Amazon managed SSL/TLS certificate which we can deploy to our ALB. (on alb.tf you can find the conditional "aws_alb_listener" resource for "https")

### 2. User_data
Leveraging the EC2 user_data we bootstrap the commands required to deploy our application.

#### update yum packages and install git and docker
yum update -y
yum install -y git docker

#### In order to run docker without sudo we add ec2 to the docker group and start docker
usermod -a -G docker ec2-user
systemctl start docker
systemctl enable docker

#### Running as ec2-user, git clone application repo and navigate to the application folder
su - ec2-user -s /bin/bash -c "cd ~;
git clone https://github.com/ferzconnect01/quest.git;
cd quest;

#### Docker build and tag image as quest:v1
docker build -t quest:v1 .;

#### Docker run container. Pass environment variable SECRET_WORD - the value is securely stored in AWS SSM parameter store.
docker run -d --restart=unless-stopped --env="SECRET_WORD=`/usr/bin/aws --region=${var.aws_region} ssm get-parameters --with-decryption --names /nva-quest-01/docker/secret --query "Parameters[*].Value" --output text`" -p 3000:3000 quest:v1"

### 3. Dockerfile
#### Declares the Base Image
FROM node:10

#### Runs the following bash commands
RUN mkdir -p /home/node/app && chown -R node:node /home/node/app

#### sets the working directory
WORKDIR /home/node/app

#### sets default user
USER node

#### Copy's src files and directories to container working directory
COPY --chown=node:node . .

#### Runs npm install and downloads the dependencies defined in a package.json
RUN npm install

#### sets default command to execute on container startup
CMD ["node", "src/000.js"]

#### Container port to Listen on
EXPOSE 3000

.dockerignore: Declare files and directories to be excluded when Docker runs ADD or COPY.

.gitignore: Declare files and directories to be excluded on git add command.

## Given more time, I would improve:
- I would deploy SSL/TLS CERT to the ALB. Given the solution I chose for this quest. My goal was to deploy a single ALB endpoint that delivered all test stages. ACM would be amongst the most appropriate method for deploying certificates.

- I would also further automate terraform workflow with a CI/CD pipeline by using github actions. Other than the automation pipelines provide, they also create more visibility, store logs for tracing and are durable.

- I would submit another entry for this quest solution in Microsoft Azure.
