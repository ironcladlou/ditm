FROM fedora:rawhide

RUN yum install --nogpg -y traceroute curl dnsutils nmap-ncat jq nmap net-tools wget iptables iproute \
    tcpdump procps-ng nftables bind-utils strace jq iptables-nft golang wireshark tmux

# Install crictl
ENV CRICTL_VERSION="v1.13.0"
RUN wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz \
    && tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin

# Install mitmproxy
RUN wget https://snapshots.mitmproxy.org/4.0.4/mitmproxy-4.0.4-linux.tar.gz \
    && tar zxvf mitmproxy-4.0.4-linux.tar.gz -C /usr/local/bin

RUN go get github.com/gcla/termshark/cmd/termshark && mv /root/go/bin/termshark /usr/local/bin

RUN alternatives --set iptables /usr/sbin/iptables-nft
