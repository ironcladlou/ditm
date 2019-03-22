FROM  nicolaka/netshoot

WORKDIR /

ENV VERSION="v1.13.0"
RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz \
    && tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
