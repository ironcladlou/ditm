# Dan in the middle

Transparently debug OpenShift containers.

## Make an image

```
$ make IMAGE=your/repo/ditm:latest build-image push-image
```

## Shell
```
$ WHAT=shell IMAGE=your/repo/ditm:latest push-image ditm <namespace> <pod>
```

Your shell is a privileged container on the same node as `<pod>`. The `CONTAINER_ID` environment variable contains the container ID for use with `crictl`. You can do things like enter the network namespace of the target pod:


```
$ PID=$(crictl inspect $CONTAINER_ID -o yaml | grep pid | awk '{print $2}')
$ nsenter -t $PID --net bash
```

## Wireshark

If you just want to sniff container traffic with a local Wireshark, try:

```
$ WHAT=wireshark ditm <namespace> <pod>
```

TODO:
- Describe how mitm can be used to do live analysis of encrypted traffic.
- Rewrite as a `kubectl` plugin
