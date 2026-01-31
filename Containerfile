ARG FEDORA_VERSION=latest

FROM registry.fedoraproject.org/fedora:${FEDORA_VERSION}

# Install base packages including curl (needed for uv install)
RUN dnf install -y \
    bubblewrap \
    socat \
    curl \
    python3.12 \
    && dnf clean all

# Install additional dev packages
COPY packages.txt /opt/packages.txt
RUN dnf install -y $(cat /opt/packages.txt) \
    && dnf clean all

# Create user and group
ARG UID=1000
ARG GID=1000
RUN useradd -u "${UID}" -g "${GID}" -m vibe
COPY sudoers /etc/sudoers.d/vibe

# Switch to vibe user for tool installation
USER ${UID}:${GID}

# Install uv (modern Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/vibe/.local/bin:${PATH}"

# Install mistral-vibe using uv
RUN uv tool install mistral-vibe

ENV BASH_ENV=/home/vibe/.bash_environment
COPY environment $BASH_ENV
RUN mkdir -p /home/vibe/.config /home/vibe/.vibe
WORKDIR /projects
ENTRYPOINT ["/home/vibe/.local/bin/vibe"]
