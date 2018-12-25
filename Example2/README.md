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
  - Pubsub queue
  - Google Cloud Storage Bucket
  - Google KMS
  - Google Source Repo
  - Google Cloud Build

# Application

- Python web api application, served with gunicorn
  - Calls main application
  - Setup with instance group
  - Application has a load balancer receiving its traffic
  - Receives jobs to fire to pubsub
- Python task application
  - Has chromedriver as well as webdriver installed on it
  - Takes screenshot and saves it into GCS
