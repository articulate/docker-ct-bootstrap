#!/bin/bash
set -eo pipefail

# Due to docker's layer caching, you may need to update this file in a way to force docker
# to skip the layer cache and re-run this install the next time it builds the image.
# Simply edit the date here: 2020-11-12

CONSUL_TEMPLATE_BOOTSTRAP_REF=$1
if [ "${CONSUL_TEMPLATE_BOOTSTRAP_REF}" == "" ]; then
  CONSUL_TEMPLATE_BOOTSTRAP_REF="master"
fi

if [ `command -v apt-get` ]; then
  apt-get update
  apt-get -y install --no-install-recommends unzip sudo python3-setuptools python3-pip jq wget curl
  pip3 install awscli
  apt-get clean && apt-get autoclean && apt-get -y autoremove --purge
  rm -rf /var/lib/apt/lists/* /usr/share/doc /root/.cache/
elif [ `command -v yum` ]; then
  grep "Amazon Linux" /etc/os-release &>/dev/null || yum -y install epel-release
  yum -y update
  yum -y install unzip jq sudo wget curl which
  wget -q -O /tmp/awscli-bundle.zip "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
  unzip -d /tmp /tmp/awscli-bundle.zip
  /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
  rm -rf /tmp/awscli-bundle*
  yum clean all
elif [ `command -v apk` ]; then
  apk add --no-cache --update unzip sudo python3 jq wget ca-certificates curl which py3-pip
  pip3 --no-cache-dir install awscli
  update-ca-certificates
  rm -rf /var/cache/apk/*
else
  echo "Existing package manager is not supported"
  exit 1
fi

# Install Consul template
CONSUL_TEMPLATE_VERSION=0.25.1
wget -q -O /tmp/consul-template.zip https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
unzip -d /usr/local/bin /tmp/consul-template.zip
rm /tmp/consul-template.zip


# Install Vault CLI
VAULT_VERSION=1.5.4
wget -q -O /tmp/vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
unzip -d /tmp /tmp/vault.zip
mv /tmp/vault /usr/local/bin/vault
chmod +x /usr/local/bin/vault
rm -rf /tmp/vault*

# Install consul-bootstrap
wget -q -O /tmp/docker-consul-template-bootstrap.zip https://github.com/articulate/docker-consul-template-bootstrap/archive/${CONSUL_TEMPLATE_BOOTSTRAP_REF}.zip
unzip -d /tmp /tmp/docker-consul-template-bootstrap.zip
mv /tmp/docker-consul-template-bootstrap-${CONSUL_TEMPLATE_BOOTSTRAP_REF}/ /consul-template/
mv /consul-template/entrypoint.sh /entrypoint.sh
rm /tmp/docker-consul-template-bootstrap.zip

##process for using awscli-bundle in case it is needed in the future
  #wget -q -O /tmp/awscli-bundle.zip "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
  #unzip -d /tmp /tmp/awscli-bundle.zip
  #sudo /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
  #rm -rf /tmp/awscli-bundle* 

for package in wget jq curl which aws consul-template vault; do
  if [ ! `command -v $package` ]; then
    echo "$package is not installed"
    exit 1
  fi
done
