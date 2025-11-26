FROM jenkins/inbound-agent:latest

USER root

# Install docker
RUN apt-get update && \
    apt-get install -y docker.io && \
    usermod -aG docker jenkins

# Install AWS CLI v2
RUN apt-get update && \
    apt-get install -y unzip curl && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Install Trivy (Official repo method – no failures)
RUN apt-get update && \
    apt-get install -y wget apt-transport-https gnupg lsb-release && \
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor -o /usr/share/keyrings/trivy.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
        > /etc/apt/sources.list.d/trivy.list && \
    apt-get update && \
    apt-get install -y trivy

# Install OWASP dependency-check
RUN mkdir /opt/owasp && \
    wget https://github.com/jeremylong/DependencyCheck/releases/download/v10.0.3/dependency-check-10.0.3-release.zip && \
    unzip dependency-check-10.0.3-release.zip -d /opt/owasp && \
    ln -s /opt/owasp/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check.sh

USER jenkins
