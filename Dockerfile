FROM jenkins/inbound-agent:jdk11

USER root
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
        gnupg \
        sudo \
        openjdk-11-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------
# Docker CLI
# -------------------------------------------------------
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
        > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

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
# Trivy
# -------------------------------------------------------
RUN wget https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh && \
    chmod +x install.sh && \
    ./install.sh && \
    rm install.sh

# -------------------------------------------------------
# OWASP Dependency Check
# -------------------------------------------------------
ENV DC_VERSION=10.0.3
RUN mkdir -p /opt/owasp && \
    wget https://github.com/jeremylong/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip && \
    unzip dependency-check-${DC_VERSION}-release.zip -d /opt/owasp/ && \
    mv /opt/owasp/dependency-check /opt/dependency-check && \
    rm dependency-check-${DC_VERSION}-release.zip
ENV PATH="/opt/dependency-check/bin:${PATH}"

# -------------------------------------------------------
# Permissions
# -------------------------------------------------------
RUN usermod -aG sudo jenkins

USER jenkins
WORKDIR /home/jenkins
