#!/bin/bash
set -euo pipefail

function usage_and_exit {
  echo "WHAT=<shell|wireshark> ${0##*/} <namespace> <pod-name>"
  exit 1
}

function render {
  sed "s~{namespace}~$NAMESPACE~;s~{name}~$NAME~;s~{image}~$IMAGE~;s~{nodeName}~$NODE~;s~{containerID}~${CONTAINER_ID:8}~" $1 > $2
  echo "wrote $2"
}

function cleanup {
  oc delete -n $NAMESPACE pods/$NAME
}

function create_pod {
  YAML=$(mktemp)
  resource=$(oc process -f $DIR/debugger.yaml NAMESPACE="$NAMESPACE" NAME="$NAME" NODE_NAME="$NODE" CONTAINER_ID="$CONTAINER_ID")
  echo $resource | oc apply -f -
  trap cleanup EXIT
  oc wait --for=condition=Ready --timeout=2m --namespace=$NAMESPACE pod/$NAME
}

function run_shell {
  create_pod
  oc exec -it --namespace $NAMESPACE $NAME -- /bin/bash
}

function run_wireshark {
  create_pod
  oc exec --namespace $NAMESPACE $NAME -- /bin/bash -c $'PID=$(crictl inspect $CONTAINER_ID -o yaml | grep pid | awk \'{print $2}\'); nsenter -t $PID --net tcpdump -U -w -' | wireshark -k -i - -o "tls.keylog_file: ${SSLKEYLOGFILE}" -o "gui.window_title:${NAMESPACE}/${TARGET}"
}

function run_nftables {
  create_pod
  oc exec --namespace $NAMESPACE $NAME -- /bin/bash -c 'nft list table ip nat'
}

NAMESPACE="${1:-}"
TARGET="${2:-}"
WHAT="${WHAT:-shell}"

IMAGE="${IMAGE:-docker.io/ironcladlou/ditm}"
SSLKEYLOGFILE="${SSLKEYLOGFILE:-/tmp/ssl_key.log}"

if [ -z "$NAMESPACE" ]; then usage_and_exit; fi
if [ -z "$TARGET" ]; then usage_and_exit; fi

DIR="$(dirname "$(readlink "$0")")"

UUID=$(uuidgen | tr "[:upper:]" "[:lower:]")
NAME="${TARGET}-debug-${UUID:0:8}"
NODE="$(oc get --namespace $NAMESPACE pods $TARGET -o go-template='{{ .spec.nodeName }}')"
CONTAINER_ID="$(oc get --namespace $NAMESPACE pods $TARGET -o go-template='{{ (index .status.containerStatuses 0).containerID }}')"
CONTAINER_ID="${CONTAINER_ID:8}"

case $WHAT in
  shell)
    run_shell
    ;;
  wireshark)
    run_wireshark
    ;;
  nftables)
    run_nftables
    ;;
  *)
    usage_and_exit
    ;;
esac
