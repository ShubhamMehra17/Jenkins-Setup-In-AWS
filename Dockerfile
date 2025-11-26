FROM ubuntu:22.04

# Noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------------
# Base packages
# -------------------------------------------------------
RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        curl \
        wget \
        unzip \
        zip \
        git \
        jq \
        make \
        apt-transport-https \
        gnupg \
        software-properties-common \
        openjdk-11-jdk \
        sudo && \
    apt-get clean

# -------------------------------------------------------
# Docker CLI
# -------------------------------------------------------
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# -------------------------------------------------------
# AWS CLI v2
# -------------------------------------------------------
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# -------------------------------------------------------
# Kubectl
# -------------------------------------------------------
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# -------------------------------------------------------
# Terraform
# -------------------------------------------------------
RUN wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip && \
    unzip terraform_1.6.6_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.6.6_linux_amd64.zip

# -------------------------------------------------------
# Trivy (universal installer – always works)
# -------------------------------------------------------
RUN wget https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh && \
    chmod +x install.sh && \
    ./install.sh && \
    rm install.sh

# -------------------------------------------------------
# OWASP Dependency Check (preinstalled)
# -------------------------------------------------------
ENV DC_VERSION=10.0.3
RUN mkdir -p /opt/owasp && \
    wget https://github.com/jeremylong/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip && \
    unzip dependency-check-${DC_VERSION}-release.zip -d /opt/owasp/ && \
    mv /opt/owasp/dependency-check /opt/dependency-check && \
    rm dependency-check-${DC_VERSION}-release.zip

ENV PATH="/opt/dependency-check/bin:${PATH}"

# -------------------------------------------------------
# Jenkins agent
# -------------------------------------------------------
RUN useradd -m -d /home/jenkins -s /bin/bash jenkins && \
    usermod -aG sudo jenkins && \
    echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER jenkins
WORKDIR /home/jenkins

# Java is already installed for JNLP agent & OWASP

# -------------------------------------------------------
# Final
# -------------------------------------------------------
CMD ["bash"]
