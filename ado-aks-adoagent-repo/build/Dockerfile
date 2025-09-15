FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG AGENT_VERSION=3.240.1
ARG USER=agent
ARG UID=10001
ARG GID=10001

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y     ca-certificates curl jq gnupg lsb-release unzip tar git     postgresql-client   && curl -sL https://aka.ms/InstallAzureCLIDeb | bash   && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GID} ${USER} && useradd -m -u ${UID} -g ${GID} ${USER}

WORKDIR /azp
RUN curl -fsSL https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz     -o agent.tar.gz  && tar -zxf agent.tar.gz  && rm agent.tar.gz

COPY install.sh /setup/install.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /setup/install.sh /entrypoint.sh
RUN /setup/install.sh

USER ${USER}
ENV ADO_URL="" ADO_POOL="" ADO_AGENT_NAME="" ADO_WORK="_work"

ENTRYPOINT [ "/entrypoint.sh" ]
