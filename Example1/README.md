# Web Application Setup

Setting up a basic web application server that requires Python 3. This sets up basic Nginx web server which would allow us to serve the sample nginx webpage.

The first part of this whole automation is to get a service account with sufficient permissions to manipulate all required infrastructure before proceeding onwards to the rest of the infra.

## Understanding whys

3 tools are used here:

- ansible: Configuration management tool
- packer: Tool to help create the VM images to run on the target platform
- terraform: Tool to bootstrap the infra

We would split the building of infra into 2 steps.

- Building/baking the vm image which should immutable and is replaceable
- Bootstrapping the infra platform

There are other aspects to this to complete the full picture such as blue/green deployment of infra etc. But this would be a decent beginning to all

# Understanding the files

- example.tfvars
  - Example terraform variable file to be used which would contain the variable bits of infrastructure. Based on this, we can configure several other aspects of the infra which could include setting labels like "This is a dev server etc"
  - Copy this to the `terraform.tfvars` for it to be picked up by the terraform tool
- Pipfile, Pipfile.lock
  - These are dependency management files to install `ansible`.
- terraform.tf
  - The terraform configuration file for this example infra setup
- image_builder.json.example
  - Using packer to bake an image with all the required values
  - Copy and adjust project value to the
- playbook.yml
  - Ansible playbook to install nginx on the server

# Packer commands to run

```bash
# Use pipenv shell - switch to shell that has ansible
pipenv shell
pipenv install

# Test that ansible commands work
ansible --version

# Check to ensure that the json file provided fits packer
packer validate image_builder.json

# Bake the image
packer build image_builder.json
```

# Terraform Commands to run

```bash
# This would pull in the google cloud module needed to run this
terraform init

# Generates a tf plan to be executed as part of the infrastructure
terraform plan -out=planned_infra

# Apply the tf plan
terraform apply planned_infra

# Destroy the infrastructure
terraform destroy
```
