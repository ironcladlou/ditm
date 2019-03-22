#!/bin/bash
WHAT="${WHAT:-shell}"

NAMESPACE="$1"
TARGET="$2"

NAME="${TARGET}-debug"
IMAGE="docker.io/ironcladlou/ocdebug"
NODE="$(oc get --namespace $NAMESPACE pods $TARGET -o go-template='{{ .spec.nodeName }}')"
CONTAINER_ID="$(oc get --namespace $NAMESPACE pods $TARGET -o go-template='{{ (index .status.containerStatuses 0).containerID }}')"

function render() {
  sed "s~{namespace}~$NAMESPACE~;s~{name}~$NAME~;s~{image}~$IMAGE~;s~{nodeName}~$NODE~;s~{containerID}~${CONTAINER_ID:8}~" $1 > $2
  echo "wrote $2"
}

YAML=$(mktemp)

if [ "$WHAT" == "shell" ]; then
  render debug-pod-shell.yaml $YAML
  oc debug -f $YAML --node-name=$NODE
elif [ "$WHAT" == "tcpdump" ]; then
  render debug-pod-exec.yaml $YAML
  oc apply -f $YAML
  oc wait --for=condition=Ready --namespace=$NAMESPACE pod/$NAME
  oc exec --namespace $NAMESPACE $NAME -- /bin/bash -c $'PID=$(crictl inspect $CONTAINER_ID -o yaml | grep pid | awk \'{print $2}\'); nsenter -t $PID --net tcpdump -U -w -' | wireshark -k -i - -o "tls.keylog_file: /tmp/keys.log"
  oc delete -f $YAML
fi
