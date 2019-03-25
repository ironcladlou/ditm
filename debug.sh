#!/bin/bash
set -euo pipefail

function usage_and_exit {
  echo "WHAT=<shell|tcpdump> ${0##*/} <namespace> <pod-name>"
  exit 1
}

function render {
  sed "s~{namespace}~$NAMESPACE~;s~{name}~$NAME~;s~{image}~$IMAGE~;s~{nodeName}~$NODE~;s~{containerID}~${CONTAINER_ID:8}~" $1 > $2
  echo "wrote $2"
}

function run_shell {
  YAML=$(mktemp)
  render debug-pod-shell.yaml $YAML
  oc debug -f $YAML --node-name=$NODE
}

function run_tcpdump {
  YAML=$(mktemp)
  render debug-pod-exec.yaml $YAML
  oc apply -f $YAML
  oc wait --for=condition=Ready --namespace=$NAMESPACE pod/$NAME
  oc exec --namespace $NAMESPACE $NAME -- /bin/bash -c $'PID=$(crictl inspect $CONTAINER_ID -o yaml | grep pid | awk \'{print $2}\'); nsenter -t $PID --net tcpdump -U -w -' | wireshark -k -i - -o "tls.keylog_file: /tmp/keys.log"
  oc delete -f $YAML
}

NAMESPACE="${1:-}"
TARGET="${2:-}"
WHAT="${WHAT:-shell}"
IMAGE="${IMAGE:-docker.io/ironcladlou/ditm}"

if [ -z "$NAMESPACE" ]; then usage_and_exit; fi
if [ -z "$TARGET" ]; then usage_and_exit; fi

NAME="${TARGET}-debug"
NODE="$(oc get --namespace $NAMESPACE pods $TARGET -o go-template='{{ .spec.nodeName }}')"
CONTAINER_ID="$(oc get --namespace $NAMESPACE pods $TARGET -o go-template='{{ (index .status.containerStatuses 0).containerID }}')"

case $WHAT in
  shell)
    run_shell
    ;;
  tcpdump)
    run_tcpdump
    ;;
  *)
    usage
    ;;
esac
