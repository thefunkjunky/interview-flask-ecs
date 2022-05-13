#!/usr/bin/env bash

terraform init -lock=false
terraform plan -lock=false
terraform apply -lock=false -auto-approve

