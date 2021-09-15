FROM debian

ENV TERRAFORM_VERSION=0.14.3
ENV KUBECTL_VERSION=v1.19.8
ENV HELM_VERSION=v3.4.2
ENV KUBESEAL_VERSION=v0.13.1

# Debug connections
RUN apt-get update \
 && DEBIAN_FRONTEND="noninteractive" apt -y install curl wget unzip git telnet curl netcat dnsutils python3-pip python3-jenkins jq gnupg gnupg2 gnupg1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ansible
RUN apt-get update \
 && apt-get -y install ansible \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# kubectl
RUN apt-get update \
 && apt-get -y install ca-certificates curl apt-transport-https lsb-release gnupg \
 && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg |  apt-key add - \
 && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" |  tee -a /etc/apt/sources.list.d/kubernetes.list \
 && apt-get update \
 && apt-get install -y kubectl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# az
RUN apt-get update \
 && apt-get -y install ca-certificates curl apt-transport-https lsb-release gnupg \
 && curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
 && AZ_REPO=$(lsb_release -cs) \
 && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
 && apt-get update \
 && apt-get -y install azure-cli \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" apt -y install php-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip terraform.zip -d /usr/bin && \
    rm terraform.zip

RUN pip3 install yq==2.11.1 crcmod

RUN curl https://sdk.cloud.google.com > install.sh && \
    bash install.sh --disable-prompts --install-dir=/opt && \
    echo "source /opt/google-cloud-sdk/path.bash.inc" >> /etc/bash.bashrc && \
    echo "source /opt/google-cloud-sdk/path.bash.inc" >> /etc/profile && \
    ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud

RUN if [ "${KUBECTL_VERSION}" == "latest" ]; then \
        curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"; \
    else \
        curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl; \
    fi \
 && chmod +x ./kubectl \
 && mv ./kubectl /usr/local/bin/kubectl

RUN curl -o helm.tgz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf helm.tgz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64

RUN wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.13.1/kubeseal-linux-amd64 -O kubeseal \
 && chmod +x kubeseal \
 && mv kubeseal /usr/local/bin/kubeseal
