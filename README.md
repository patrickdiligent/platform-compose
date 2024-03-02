### Synopsis

Deploy the ForgeRock 7.4 platform on docker containers with docker-compose orchestration, using the ForgeRock base docker images.

### In a nutshell

Note: make sure the docker image have enough resources (I boosted Docker Desktop on Mac to 8G)

1. Clone the git repository
	```bash
	$ mkdir /path/to/project; cd /path/to/project
	$ git clone ssh://git@stash.forgerock.org:7999/proserv/platform-compose.git
	$ cd platform-compose
	```
1. Adjust the FQDN variable in `compose/sandbox/.env`. Default is `platform.example.com`. 

1. Generate SSL certificate and key for the selected domain, and copy them under `compose/sandbox/nginx/certs`, as `platform-crt`, and `platform-key.pem`, as shown in the `nginx` spec:
	
   ```yaml
	nginx:
		image: nginx

		volumes:
		- ./nginx/default.conf.template:/etc/nginx/conf.d/default.conf.template
		- ./nginx/certs/platform.crt:/etc/nginx/ssl.crt
		- ./nginx/certs/platform-key.pem:/etc/nginx/ssl-key.pem
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
		$ cd platform-compose/compose/sandbox
		$ bin/init-config.sh
	```

1. Build the Docker Images
	```bash
	$ cd platform-compose/compose/sandbox
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
		And wait for the initialisation to complete (Wait for `"impexp.local     | Export completed successfully"` ) in the log.

	1. Point the browser to `https://<FQDN>/am` for the AM admin UI - `amadmin`/`password`
	1. Point the browser to `https://<FQDN>/admin` for the IDM admin ui - `amadmin`/`password`
	1. Point the browser to `http://<FQDN>/platform` to access the platform admin UI
	1. Point to `http://<FQDN>/enduser` for self-service,
	1. Point to `http://<FQDN>/login` for the central login page.

#### NGINX Logging configuration

NGINX log with colour highlights:

```
$ brew install grc
$ cp nginx/conf.platformnginx ~/.grc
$ grc --config conf.platformnginx docker logs -f nginx.local
```

More info at the [grcat project page](https://github.com/garabik/grc).
