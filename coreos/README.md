# AngelBox

On your journey to be the next "shopify" or "ebay", AngelBox is designed to be the first
step, and in anticipation of your rapid rise to greatness, the final destination envisaged
is the cloud-vendor-independent but very impressive,
"[Red Hat OpenShift Container Platform](https://www.openshift.com/products/container-platform "Watch the Video")"

AngelBox is the new AMP/WAMP/MAMP for zero outlay, local development of a production ready system.
With AngelBox the intention is to create a fully deployed and secure cluster of services, 
and use this for "local" development.

The starting point, is a small dedicated set of services that a developer selects
and configures. Add an `angel` folder to your project, and AngelBox will create and
manage for you a production ready set of services managed through `docker-compose`.

## Using Fedora CoreOS with Angelbox

AngelBox is being designed with Fedora CoreOS as an expected deployment target for both
small scale production environments and production-ready developer setups.

When you need to scale, then Fedora Core OS can be provisioned and scaled on all the usual
cloud providers OR on your in-house bare metal. When the time comes it is but a "small"
step to scale up further using a comprehensive commercial cluster management solution (OpenShift)

### FCCT - Fedora CoreOS Configuration Transpiler

We provision our machines with a `.yaml` file, but *FCOS* actually uses `ignition` which 
takes a `.json` file as it's input. This is because by design ignition specifications are 
supposed to be "human readable, but not human writable".

You can download the fcct binary from github (this is the mac binary)
```
curl https://github.com/coreos/fcct/releases/download/v0.2.0/fcct-x86_64-apple-darwin -o ~/bin/fcct
chmod a+x ~/bin/fcct
```

