# Use the official Jenkins LTS image
FROM jenkins/jenkins:lts

# Switch to root user to install dependencies
USER root

# Set default architecture for Docker and Google Cloud SDK
ARG TARGETARCH

# Install dependencies for Docker, Google Cloud SDK, and kubectl
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common && \
    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    # Set up the stable Docker repository
    echo "deb [arch=${TARGETARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker.io && \
    # Add Google Cloud SDK’s official GPG key
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud-google-archive-keyring.gpg && \
    # Set up Google Cloud SDK repository
    echo "deb [signed-by=/usr/share/keyrings/cloud-google-archive-keyring.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null && \
    apt-get update && \
    apt-get install -y google-cloud-sdk && \
    # Install kubectl based on architecture
    if [ "$TARGETARCH" = "arm64" ]; then \
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"; \
    else \
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
    fi && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    # Clean up unnecessary files
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add Jenkins to the Docker group (skip group creation if it already exists)
RUN usermod -aG docker jenkins

# Switch back to the Jenkins user
USER jenkins

# Make sure gcloud is in the Jenkins user's PATH
ENV PATH "$PATH:/google-cloud-sdk/bin"

