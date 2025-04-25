FROM codercom/code-server:4.99.3

USER root

# Install necessary packages (wget, unzip for Terraform, prerequisites for Docker CLI)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Install Terraform
# Consider using a newer version if appropriate for your needs
ARG TERRAFORM_VERSION="1.11.3"
RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    mv terraform /usr/local/bin && \
    rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Install Docker CLI (using official Docker DEBIAN repository)
RUN mkdir -p /etc/apt/keyrings && \
    # Use the Debian GPG key URL
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
      # Use the Debian repository URL
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y --no-install-recommends docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# --- Java (OpenJDK) ---
# Define Java Version (e.g., 17 for LTS)
ARG JAVA_VERSION=17
RUN apt-get update && \
    apt-get install -y --no-install-recommends "openjdk-${JAVA_VERSION}-jdk" && \
    # Clean up APT cache
    rm -rf /var/lib/apt/lists/*

# --- Node.js ---
# Define Node.js Major version (e.g., 20 for LTS as of late 2023/early 2024)
ARG NODE_MAJOR=20
# Setup NodeSource repository
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
# Install Node.js
RUN apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    # Clean up APT cache
    rm -rf /var/lib/apt/lists/*

# --- Helm ---
# Install Helm (using official script)
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod +x get_helm.sh && \
    ./get_helm.sh && \
    rm get_helm.sh

# --- Kubectl ---
# Define Kubectl version (defaulting to 1.30.6)
ARG KUBECTL_VERSION="1.30.6"
# Install specific Kubectl version (controlled by build-arg)
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

USER coder
