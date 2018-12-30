# Python Web application setup

This is a more complex setup that builds on what happens from Example 1

This assumes more of the engineering workflows. E.g. One would build quite often as compared to refreshing the infrastructure

Application's main goal is take screen shots of website and store it on Google Cloud Storage

This example would take on the following:

- Setting up Cloud Repository to temporarily host the repo
  - This is to make it easier to utilize the `Cloud Build`
- Using Google KMS to store secrets
  - This is to be used in order to handle the service accounts on Cloud Build
- Setting up Build infrastructure on Google Cloud
  - For ease, we would use Cloud Build which is already quite decent. Setting up of Cloud Build and its triggers
  - Cloud build repository will use a `cloudbuild.yaml` file to have its build configured
  - Cloud Build would produce GCE VM images that can be immediately be used in the infrastructure
- Architecture to be setup for this
  - Web application instance group that can be scaled accordingly based on mem/cpu usage
  - Task application instance group that can be scaled according to items on the pubsub queue
  - Google Cloud SQL
  - [x] Pubsub topic
  - [x] Pubsub subscription
  - [x] Google Cloud Storage Bucket
  - [x] Google KMS
  - [x] Google Source Repo x3
    - Ansible scripts
    - Web API Repo
    - Task Repo
  - [x] Google Cloud Build Triggers x2
    - Web API Repo Trigger on Master
    - Task Repo Trigger on Master

# Application

- Python web api application, served with gunicorn
  - Calls main application
  - Setup with instance group
  - Application has a load balancer receiving its traffic
  - Receives jobs to fire to pubsub
- Python task application
  - Has chromedriver as well as webdriver installed on it
  - Takes screenshot and saves it into GCS

# Cloud Build Image

We would need to create a cloud build image for us to use. This cloud build image would need to contain both `ansible` and `packer` tools installed on it. The image would need to be sent to the respective GCP project for use.

# Running commands

These are the set of commands to run to set everything up as expected.  
(Note: It takes 5-10 mins to spin up a MySQL instance)  
This set of commands are to be done assuming on a fresh google cloud project

We would split the execution to several parts:

1. Running commands to have enable APIs.
2. Create the service account with `EDITOR` access. (Future developments would require the service account to have more restrictive capabilities)
3. Run terraform and spin up infra with service account generated (part 1)
4. Add the cloud build image to allow building of google images
5. Start pushing code and generate the new vm images to be used for the application (part 2)

## Running commands to enable APIs

```
gcloud project set project [PROJECT_ID]
gcloud services list --available

gcloud services enable sourcerepo.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable storage-component.googleapis.com
```

## Terraform Commands to run

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
