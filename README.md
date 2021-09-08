
# k8s-less CDK-like devops deployment

### Synopsis

Deploy the ForgeRock 7.1 platform on docker containers with docker-compose orchestration, and using the vanilla (almost) ForgeRock base docker images;  this is targetted at testing/learning/experimentation/development, this is not with production in mind.

### In a nutshell

Note: make sure the docker image have enough resources (I boosted Docker Desktop on Mac to 8G)

1. Clone the git repository
	```bash
	$ mkdir /path/to/project; cd /path/to/project
	$ git@bitbucket.org:patrickdiligentfr/forgeops-compose.git
	$ cd forgeops-compose
	```
1. Copy the Product packages
	```bash
	$ cd docker/am/build; unzip /path/to/AM-7.1.0.zip
	$ cd docker/am/build/amster; unzip /path/to/Amster-7.1.0.zip
	$ cp /path/to/IDM-7.1.0.zip docker/idm/idm-base/
	$ cp /path/to/DS-7.1.0.zip docker/ds/ds-base/
	```
1. Adjust the FQDN variable in `compose/sandbox/.env`. Default is `platform.example.com`. 

1. Generate SSL certificate and key for the selected domain, and copy them under `compose/sandbox/nginx/certs`, as `platform-crt`, and `platform-key.pem`, as shown in the `nginx` spec:
	
	```yaml
	nginx:
		image: nginx
		...
		volumes:
		- ./nginx/default.conf.template:/etc/nginx/conf.d/default.conf.template
		- ./nginx/certs/platform.crt:/etc/nginx/ssl.crt
		- ./nginx/certs/platform-key.pem:/etc/nginx/ssl-key.pem
    ...
    ```
	
	To generate the certificates: 

    ```bash
	$ cd compose/sandbox/nginx/
	$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/platform-key.pem -out certs/platform.crt
	...
	Common Name (eg, fully qualified host name) []:platform.example.com
	Email Address []:
	```
1. Propagate the configuration to be baked into the Docker images:

	```bash
		$ cd docker-dev/compose/sandbox
		$ bin/init-config.sh
	```

1. Build the Docker Images
	```bash
	$ cd docker-dev/compose/sandbox
	$ docker-compose build
	```

1. Revisit the components security artefacts (provided by default in `compose/sandbox/security`).

	The keystores for IDM, DS, and AM are located under `compose/sandbox/security`. These are made available to the images via mounted volumes.

1. Bring it up
	1. Deploy
		```bash
		$ cd compose/sandbox
		$ docker-compose up
		```
		And wait for the initialisation to complete (Wait for `"impexp.sdx.local     | Export completed successfully")` in the log.

	1. Point the browser to `https://<FQDN>/am` for the AM admin UI - `amadmin`/`password`
	1. Point the browser to `https://<FQDN>/admin` for the IDM admin ui - `amadmin`/`password`
	1. Point the browser to `http://<FQDN>/platform` to access the platform admin UI
	1. Point to `http://<FQDN>/enduser` for self-service,
	1. Point to `http://<FQDN>/login` for the central login page.

1. Optional, generate sample user data to play with:

	```bash
	$ docker exec -it idrepo.sdx.local /opt/opendj/bin/make-users.sh 200
	```
#### Config Versioning

* The versioned config is located under `docker-dev/config`

* To export the configuration (from a running deployment):
	```bash
		$ cd docker-dev/compose/sandbox
		$ bin/export-config.sh
	```
	The configuration is exported in `docker-dev/config/stage`

* To save the configuration (and further commit after verification):

	```bash
		$ cd docker-dev/compose/sandbox
		$ bin/save-config.sh
	```
	This saves the configuration to `docker-dev/config/idm, am, amster`. It is ready to be committed.

	`save-config.sh` runs `upgrade-config.sh` replacing selected values with their respective configuration placeholders, and replacing encrypted password values with clear a configured clear text value for selected IG agents and OAuth2 clients. 

* To build new images with the new configuration:

	```bash
		$ cd docker-dev/compose/sandbox
		$ bin/init-config.sh
		$ docker-compose build
	```

* Note that since the `idrepo` persists data on a mounted volume, comment out  these lines in `docker-compose.yaml` in the `impexp` spec, to avoid re-importing data that is already persisted:
	```yaml
	# deploy:
    #   replicas: 0
	```
#### NGINX Logging configuration

NGINX log with colour highlights:

```
$ brew install grc
$ cp nginx/conf.platformnginx ~/.grc
$ grc --config conf.platformnginx docker logs -f platform_nginx_1
```

More info at the [grcat project page](https://github.com/garabik/grc).