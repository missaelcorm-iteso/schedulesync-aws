FROM alpine:3.20.3
ARG TERRAFORM_VERSION=1.9.8
ARG TFSEC_VERSION=1.28.11
RUN apk add --no-cache --virtual .sig-check gnupg bash curl
RUN wget -O /usr/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64 \
    && chmod +x /usr/bin/tfsec
RUN cd /tmp \
    && wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && wget https://keybase.io/hashicorp/pgp_keys.asc \
    && gpg --import pgp_keys.asc \
    && gpg --fingerprint --list-signatures "HashiCorp Security" | grep -q "C874 011F 0AB4 0511 0D02  1055 3436 5D94 72D7 468F" || exit 1 \
    && gpg --fingerprint --list-signatures "HashiCorp Security" | grep -q "34365D9472D7468F" || exit 1 \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig \
    && gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS || exit 1 \
    && sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1 | grep -q "terraform_${TERRAFORM_VERSION}_linux_amd64.zip: OK" || exit 1 \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin \
    && curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash \
    && rm -rf /tmp/* && apk del .sig-check