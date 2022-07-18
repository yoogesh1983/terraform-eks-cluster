# Eks Using terraform
> terraform init </br>

> terraform plan </br>

> terraform apply --auto-approve </br>

> terraform destroy --auto-approve </br>

# Command to run after the cluster is created
> aws eks --region us-east-2 update-kubeconfig --name eks --profile terraform

# Things to remember while destroying
- <span style="color:red;">Don't forget to delete any loadbalancers manually as terraform cannot delete load balacers programmatically</span>

