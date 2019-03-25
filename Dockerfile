from fedora

RUN yum install -y wget iptables iproute tcpdump

# Install crictl
ENV CRICTL_VERSION="v1.13.0"
RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz \
    && tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin

# Install mitmproxy
RUN wget https://snapshots.mitmproxy.org/4.0.4/mitmproxy-4.0.4-linux.tar.gz \
    && tar zxvf mitmproxy-4.0.4-linux.tar.gz -C /usr/local/bin
