FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERRAFORM_VERSION=1.8.5
ENV AWSDAC_VERSION=0.4.0

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    tar \
    git \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Terraform
RUN wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

WORKDIR /app

CMD ["/bin/bash"]