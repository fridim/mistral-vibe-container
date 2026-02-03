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
RUN groupadd -g "${GID}" vibe
RUN useradd -u "${UID}" -g "${GID}" -m vibe
COPY sudoers /etc/sudoers.d/vibe

# Install Rust toolchain using rustup
USER root
RUN su - vibe -c "rustup-init -y --default-toolchain stable --profile default" \
    && su - vibe -c "source /home/vibe/.cargo/env && rustup component add rustfmt clippy"
USER ${UID}:${GID}

# Install uv (modern Python package manager)

# Install uv (modern Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/vibe/.local/bin:/home/vibe/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin:${PATH}"

# Install mistral-vibe using uv
RUN uv tool install mistral-vibe

ENV BASH_ENV=/home/vibe/.bash_environment
COPY environment $BASH_ENV
RUN mkdir -p /home/vibe/.config /home/vibe/.vibe
WORKDIR /projects
ENTRYPOINT ["/home/vibe/.local/bin/vibe"]
