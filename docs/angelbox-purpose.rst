.. include:: /_includes/snippets/__ANNOUNCEMENTS__.rst

.. _angelbox-purpose:

****************
AngelBox purpose
****************

On your journey to be the next "ebay", AngelBox is designed to be the first
step, while in anticipation of your rapid rise to greatness, the final destination envisaged
is the cloud-vendor-independent but very impressive, Red Hat `OpenShift`_™

The intention is to provide a simple framework *(i.e. structure and tools)* 
for **you** to create, share or adopt a well curated set of containers ready for
your own **production** use.

AngelBox is the new AMP/WAMP/MAMP for zero outlay, "local" development of a production ready system, 
using the parallel deployment paradigm. 
AngelBox enables you to create a fully deployed and secure cluster of services, 
and use this for "local" development in parallel to deployed services.

The starting point, is a small dedicated set of services that a developer selects
and configures. Add an `angel` folder to your project, and AngelBox will create and
manage for you a production ready set of services managed through `docker-compose`.

AngelBox aims to provide a well crafted container based environment for **any** deployment purpose.
This may include LAMP or MEAN stacks, xwiki, wordpress, laravel, or **anything** that may be found
in the **docker/container** universe.

DevilBox Redeemed
=================

While Devilbox_ focuses on getting the developer up and running quickly with a local environment. 
Angelbox focuses on providing a production ready platform, that may also be used for development. 

Parallel Deployment
===================

AngelBox closes the gap between development and production, 
and is particularly designed for modern workflows whereby both release and beta code is made available
to users and testers according to a continuous integration and release model.
This model envisages multiple code-branches published to a production ready environment, 
with additional security measures to ensure that they only reach the intended audience.

.. _Devilbox: http://devilbox.org/
.. _OpenShift: https://www.openshift.com/products/container-platform

Target Platforms
================
The main goal is to support a few rock-steady deployment targets (container runtime environments),
with the expectation that development can also be performed remotely.

.. note::

   In practice we actually use local development target servers,
   typically a bare metal Fedora Core OS Server.

Why did I build this?
=====================

Docker has created a great diversification, and with that lots of extra complexity. 
I created AngelBox in an effort to simplify and capture **in code**
a knowledge-base of production-worthy best practices.

When developers share their creations they often publish a :code:`docker-compose.yml` file to
help the user get up and running, but this is rarely more than a tutorial set-up. 

AngelBox takes this to the next level, building on :code:`docker-compose` to provide 
production-ready services in a modular fashion.

Deploying to Fedora CoreOS, takes `docker-compose` to the max, and it is s simple step up to
deployment with `docker swarm`. However, by this point it is probably time to start thinking about 
using _OpenShift™ to manage the complexity.

Simplification is Key
=====================

AngelBox aims to take some basic simple principles and apply them across the board to get
the best result for the least effort.

Building From Sources
=====================

Since production environments often have very specific requirements we do not shy away
from building our own docker images from sources where this is useful. 
This knowledge is also captured herein.

.. note::

   Our bare metal server is showing its age and required a build of *Openresty* with a
   reduced CPU instruction set. Having gone to all of that trouble, AngelBox provides a 
   structure within which to publish that knowledge.

AngelBox So Far
===============

* Deployed/Tested on Fedora Atomic Host(29)
* MariaDB / Mysql / Mysql_cli
* php_apache
* OpenResty - resty (with autossl/letsencrypt)
* php_fpm

Automation is key
=================

Next up is to create a fully automated and generalized build infrastructure
for all custom Docker images.

The outcome *will be*:

* Docker images are generated and verified.
* Docker images have extensive CI tests.
* Docker images are automatically built, tested and updated every night and pushed on success

Issues with Docker encountered
==============================

One of the major issues encountered with Docker is the syncronization of file and
directory permissions between local and Docker mounted directories.

cytopia writes: 
   This is due to the fact that the process of PHP or the web server usually run with a different
   ``uid`` and ``gid`` as the local user starting the Docker container. Whenever a new file is created
   from inside the container, it will happen with the ``uid`` of the process running inside the
   container, thus making it incompatible with your local user.

This problem has been finally addressed in Devilbox, and may need to be carried over to AngelBox
and you can read up on it in detail here: `syncronize_container_permissions`_.

.. _syncronize_container_permissions: https://devilbox.readthedocs.io/en/latest/readings/syncronize-container-permissions.html#syncronize-container-permissions

AngelBox ... Devilbox redeemed
==============================

Devilbox is used on a daily basis and its developers are finding more and more edge
cases that are being resolved. As technology also advance quickly, we all need to keep up.
The next major milestones for Devilbox were listed as:

1. to modularize it for easier customization and provision of additional containers
2. to harden it up for production usage
3. workflows for deployments in a CI/CD landscape.

**These are the present goals of AngelBox.**


