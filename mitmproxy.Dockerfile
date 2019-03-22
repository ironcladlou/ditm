FROM mitmproxy/mitmproxy

WORKDIR /

ENV CRICTL_VERSION="v1.13.0"

RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz \
    && tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin