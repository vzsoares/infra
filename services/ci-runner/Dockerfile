FROM alpine:3.20

ARG PRODUCT="terraform"
ARG VERSION="1.9.3"

# basic
RUN apk add bash && \
    apk add make && \
    apk add zip && \
    apk add docker && \
    apk add git

# install terraform
# https://developer.hashicorp.com/well-architected-framework/operational-excellence/verify-hashicorp-binary
RUN apk add --update --virtual .deps --no-cache gnupg && \
    cd /tmp && \
    wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_linux_amd64.zip && \
    wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS && \
    wget https://releases.hashicorp.com/${PRODUCT}/${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS.sig && \
    wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import && \
    gpg --verify ${PRODUCT}_${VERSION}_SHA256SUMS.sig ${PRODUCT}_${VERSION}_SHA256SUMS && \
    grep ${PRODUCT}_${VERSION}_linux_amd64.zip ${PRODUCT}_${VERSION}_SHA256SUMS | sha256sum -c && \
    unzip /tmp/${PRODUCT}_${VERSION}_linux_amd64.zip -d /tmp && \
    mv /tmp/${PRODUCT} /usr/local/bin/${PRODUCT} && \
    rm -f /tmp/${PRODUCT}_${VERSION}_linux_amd64.zip ${PRODUCT}_${VERSION}_SHA256SUMS ${VERSION}/${PRODUCT}_${VERSION}_SHA256SUMS.sig && \
    apk del .deps

# install node
RUN apk add --update nodejs npm

# install python
RUN apk add python3 && \
    apk add py3-pip

# install aws cli
RUN pip install --break-system-packages aws-sam-cli==1.121 && \
    pip install --break-system-packages awscli==1.33

# install deps
RUN npm install -g nx@^19 yarn@^1

# configure
RUN aws configure set default.region us-east-1 && \
    aws configure set default.output json
