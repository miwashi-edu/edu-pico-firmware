FROM ubuntu:24.04

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive
ENV PICO_SDK_PATH=/home/dev/ws/pico-sdk

# Install SSH server and basic utilities only
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Create dev user with password 'dev'
RUN useradd -m -s /bin/bash dev && \
    echo "dev:dev" | chpasswd && \
    usermod -aG sudo dev && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Create the firmware drop folder (will be linked to host)
RUN mkdir -p /firmware && chown dev:dev /firmware
RUN echo 'export PICO_SDK_PATH=/home/dev/ws/pico-sdk' >> /home/dev/.bashrc
RUN echo 'export PICO_SDK_PATH=/home/dev/ws/pico-sdk' >> /home/dev/.profile

# Set working directory for dev user
WORKDIR /home/dev

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
