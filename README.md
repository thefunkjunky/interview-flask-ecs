# DevOps Practical Exercise - AWS

## Primary Task:

Create a very simple REST API that when its endpoint is called, it returns one object from S3 that is a JSON file.  For example GET `/api/foo` returns contents of JSON file with something like `{ "greeting": "I am the Foo" }`. But really do whatever you want there as long as it accesses S3 to get the content.  You can create this in any development language with any framework, or you can use a sample app from somewhere online (note your source if you do so).  If you need help with this, let me know.  Keep this simple, its a 10-20 line app at most.

* Use infrastructure as code (i.e. Terraform, Pulumi, or other)
* You may use containers or instances for the application backend, or make a case for other options
* Deploy the backend to VPC / private network
* Create your own S3 bucket for the JSON files
* Make the service autoscale
* Expose the service through a termination on publicly accessible network

## Bootstrapping instructions
1. Install the latest terraform, docker, and awscli applications to your local machine.
1. configure aws access credentials in ~/.aws per https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
1. Edit all `config.tf` and `variables.tf` files in each folder under `global` and `environments` directories to match the desired bucket names, regions, and other parameters for your environment. `realm` referrs to either the account name, or the application name.  It is used along with `company` to generate unique names for AWS resources. **The defaults should work once I clean up and destroy everything in my AWS**.
1. Copy `config.tf` to `config.tf.remote` under the `global/backend` folder.
1. Execute `./bootstrap.sh` under the `global/backend` folder. Copy the json bucket id from the output.
1. Execute `./bootstrap.sh` under the `global/ecr` folder.  Copy the `base_ecr_url` from the outputs.
1. cd to app/
1. Update `config.json` to the json bucket id above.
1. Log in to your AWS console, set the region to where the ECR repo is located, and view the Elastic Container Registry dashboard.  Select the repo, and hit the "View Push Commands" button.  Follow the instructions to build and deploy the application container to the repo created above.  It should look something like this:
  ```
  aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-alias>.dkr.ecr.<your-region>.amazonaws.com

  docker build -t theoremone-interview .

  docker tag theoremone-interview <your-account-alias>.dkr.ecr.<your-region>.amazonaws.com/theoremone-interview:latest

  docker push <your-account-alias>.dkr.ecr.<your-region>.amazonaws.com/theoremone-interview:latest
  ```
1. cd to `environments/prod` and run `./bootstrap.sh`.  This will launch all VPC, IAM, and ECS resources.  The ECS cluster will launch a service that runs the python application task.
1. Copy the output value for `lb_dns`. Wait a few minutes, then run `curl [lb_dns]/api/foo` to see json message.

## Design consideration
I created a Python flask app for the application, since it is the language and framework I'm most proficient in.

All infrastructure is managed by Terraform, the most robust platform for IaC.  Also the one I'm most proficient at. The terraform state is hosted on an S3 backend, with state locking provided by DynamoDB tables. The state backend bucket is managed in Terraform, and its `bootstrap.sh` script mitigates the chicken-and-egg problem.

The primary options for hosting the app would be EC2, Lambda, ECS, or EKS.  EC2 is too heavyweight for this kind of app, and there is no benefit to using a full linux OS.  Furthermore, it would require configuration management of some kind, which not only complicates things, but introduces problems due to its imperative nature and mutability. Lambda would be ok, but that uses too much "automagic" on the backend, without the ability to designate a VPC subnet to host it in.

A lightweight, immutable container would be ideal for this kind of app, so it raises the question of which container scheduler to use: ECS, or EKS.  EKS is the heavyweight option, with a ton of features and the benefit of portability.  However, it is more complex to operate, especially in Terraform. I also feel its implementation on AWS leaves something to be desired, in terms of features and ease of use.  ECS is a more established product on AWS, and comes with the benefit of simple (or sometimes automatic) integration with AWS's Cloudwatch/Logging, load balancers, ECR, autoscaling, IAM, etc.

Therefore, the app would be containerized using Docker, uploaded to an AWS ECR repository, and scheduled via ECS.

The best structure for the Terraform that I have found is to separate globally shared resources such as the state backend and ECR repository, from environment specific resources such as the VPC and ECS.  This ensures that upstream dependencies are handled first, with no cyclic dependency issues.  Furthermore, it allows one to destroy and create environments without affecting the state backend or ECR repositories.

Due to a tricky problem I encountered, I moved the ECS services to the public subnet for troubleshooting purposes.  The issue resolution had nothing to do with this, but I was told it was fine to leave it public.  Therefore I will leave it, but it is not difficult to move it back to private if need be.

Although not specified in the requirements, I set up application logging in Cloudwatch.  ECS automatically set up metrics and alarms, including resource under-utilization, which is nice.

Autoscaling is set to 80% of cpu or memory.

## Nice to have
Things that should be in place, but time constraints prevent me from implementing it:
- Python app should be using production hardened Gunicorn WSGI instead of the default.
- Python app should only output logs in structured JSON, not plaintext.
- ECS should be moved back to private, although current security groups should prevent any mischief.
- Static, hard coded values for Terraform state backend should be auto-generated using Python Mako templates, not changed manually.  It is not possible to use variables here.
- Bootstrapping, docker build and push, and terraform plan/apply should be automated using Python script, and set in a CI/CD pipeline.
- Needs a CI/CD pipeline.
- Prod should not be automatically pulling "latest" tagged docker images, and should be use something more specific (like ":prod") to allow for control over deployments in multiple environments.
- Needs tests for both python app and terraform code, which should be part of the CI/CD pipeline.
- JSON data used in this context would be better suited for a NoSQL key:value store, or a document db.

## Authors
- Garrett Anderson <garrett@devnull.rip>
