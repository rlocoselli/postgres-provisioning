# docker-container-provisioning
This terraform project contain some examples on how to build AWS resources in order to provision Postgres database

## Installing

Initialize terraform 

``` terraform init ```

Create a variable files and fill with requested variables

``` terraform plan -var-file="./variables.tfvars" -out="provisioning.tfstate" ```

Apply infra changes

``` terraform apply provisioning.tfstate ```

Destroy infra changes

``` terraform apply -destroy -var-file="./variables.tfvars" ```
