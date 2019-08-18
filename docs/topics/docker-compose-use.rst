.. include:: /_includes/snippets/__ANNOUNCEMENTS__.rst

.. _docker-compose-use:

Docker-Compose-Use
==================

:ref:`AngelBox<angelbox-purpose>` provides a framework for running compositions of docker images.
The most obvious tool for this is :code:`docker-compose`, but ironically, the one thing that
it is absolutely lousy at is "composition".

:code:`docker-compose` uses one single :code:`.yml` file to specify a **composition** of
services. We use a simple method that can be applied to any and
every docker/OCI image to **compose** this **composition**.

Each image is represented by its own :code:`.yml` file in which all
of the important features are exposed as variables.

Usage
-----

The script :code:`docker-compose-use` creates the :code:`.env` file for :code:`docker-compose` to use.
Processing 2 or more input files.

.. code-block:: bash

    docker-compose-use <composition.env> <variables1.env> [ <variables2.env> ... ]

1. a `composition.env` - the list of services to be composed
2. specific variables provided by the target server.
3. a set of variable values for this deployment. 

e.g.

.. code-block:: bash

   docker-compose-use my-services.env /etc/angelbox/server.env $(hostname).env

The file format for (1) is simply the original :code:`.env` file format **but** 
*with line continuations enabled, and both blank lines comments are ignored*.
That was the only change necessary to make :code:`docker-compose` "composable"
and a little more "readable".

Example :code:`composition.env`:

.. code-block:: bash

   COMPOSE_FILE=box-begin.yml:\
   
      hub/official/mysql.yml:\
      hub/official/mysql/+file-secrets.yml:\
    
      box-end.yml

Example :code:`variables1.env`:

.. code-block:: bash

	MYSQL_IMAGE=mariadb/10.4-bionic
	MYSQL_PORTS_3306=4000

Conventions
-----------

- Additions/Variations are provided in a folder with the name of the service.
- Overrides are indicated by the `+` in the filename.
- Variable names follow a predictable convention.



