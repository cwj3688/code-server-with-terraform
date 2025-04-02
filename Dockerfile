FROM codercom/code-server:4.19.0

USER root

RUN apt-get update && apt-get install -y wget unzip

ARG TERRAFORM_VERSION="1.11.3"
RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    mv terraform /usr/local/bin && \
    rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

RUN terraform version

USER coder
