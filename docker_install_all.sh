#!/usr/bin/env bash

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else 
        echo "Unknown distro"
        exit 1
    fi
}

install_docker_debian() {
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/${DISTRO}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO} \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_docker_centos() {
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
}

install_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# auto-completion for Docker Compose
install_docker_compose_completion() {
    sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
}

detect_distro
case $DISTRO in
    debian|ubuntu)
        install_docker_debian
        ;;
    centos|fedora)
        install_docker_centos
        ;;
    *)
        echo "Not supported $DISTRO."
        exit 1
        ;;
esac

install_docker_compose
install_docker_compose_completion

sudo usermod -aG docker $USER

echo "Docker and Compose installed with success. Close terminal and reopen it."
