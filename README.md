# javatools steps
1. determine target container id
1. determine which node the pod is running on
1. deploy config.gatekeeper.yml
1. uncomment spec.nodeName and set appropriately in dntracer.pod.yaml if using a multinode cluster.
1. deploy javatools.pod.yaml
1. perform rest of steps inside java-tools pod via kubectl exec `kubectl exec -it java-tools -- /bin/bash`
1. determine the PID of the target process
```
# This can be somewhat tricky, ps and grep are probably the easiest way to determine the real PID.
chroot /host
ps aux | grep java
# copy the appropriate PID and use as $PID when we execute the profiler later
/var/lib/rancher/rke2/bin/ctr --address /run/k3s/containerd/containerd.sock -n k8s.io c info $CID | jq -r '.Spec.mounts[] | select(."destination" | contains("tmp")).source'
# copy the command output from above to use as $REALTMP path below.
exit
```

The CPU profiling tool requires our library to be present in the same location as the target container, so we'll copy our payload to /tmp for our tracing container and the target container.

1. symlink real path of tmp to /tmp/tmp `ln -s $REALTMP /tmp/tmp`
1. if not running async profiler, you can skip the next two steps.
1. cp /app/async-profiler-2.6-linux-x64 to /tmp
1. cp /app/async-profiler-2.6-linux-x64 to /tmp/tmp
1. execute the desired tool.

## jmap example

1. execute `jmap -dump:format=b,file=/tmp/dump.b $PID`
1. mv jmap output to our tracing container `mv /tmp/tmp/dump.b /tmp/dump.b`
1. run from your workstation `kubectl cp java-tools:/tmp/dump.b dump.b` to copy the locally.

When finished, be sure to delete the java-tools pod and gatekeeper config that were applied.

## profile.sh example

1. execute `/tmp/async-profiler-2.6-linux-x64/profiler.sh -d 30 -f /tmp/profile.html $PID`
1. mv profiler output to our tracing container `mv /tmp/tmp/profile.html /tmp/profile.html`
1. run from your workstation `kubectl cp java-tools:/tmp/profile.html profile.html` to copy the locally.

When finished, be sure to delete the java-tools pod and gatekeeper config that were applied.

# With kubectl-flame (not working)

This tool has built in java CPU stack tracing abilities, but not other tools.

It does not currently support containerd systems, it should be easy enough to add support.