[![](https://github.com/qwc-services/qwc-qgs-cache-preseed/workflows/build/badge.svg)](https://github.com/qwc-services/qwc-qgs-cache-preseed/actions)
[![docker](https://img.shields.io/docker/v/sourcepole/qwc-qgs-cache-preseed?label=Docker%20image&sort=semver)](https://hub.docker.com/r/sourcepole/qwc-qgs-cache-preseed)

QWC QGS Cache Pre-Seed
======================

Docker image for pre-seeding the QGIS Server QGS project cache.

This image will periodically query the capabilities for all/selected QGS projects below
the projects directory to ensure that the projects are cached in the QGIS Server
project cache, helping to avoid slow server responses which occur when a project
is not in cache.

Setup
-----

Add the `qwc-qgs-cache-preseed` container configuration to your QWC `docker-compose.yml`:
```yml
  qwc-qgis-server:
    image: docker.io/sourcepole/qwc-qgis-server:<tag>
    environment:
      FCGI_MIN_PROCESSES: 10
      FCGI_MAX_PROCESSES: 10
      ...
    volumes:
      - ./volumes/qgs-resources:/data:ro
      ...
      
  qwc-qgs-cache-preseed:
    image: docker.io/sourcepole/qwc-qgs-cache-preseed:<tag>
    environment:
      EXECUTE_ON_STARTUP: 1
      CRON_SCHEDULE: "0 3 * * *"
      QGS_EXT: ".qgs"
      FCGI_INSTANCES: 10
    volumes:
      - ./volumes/preseed_services.txt:/preseed_services.txt:ro
      # OR
      # - ./volumes/qgs-resources:/data:ro
```

Configuration
-------------

To control which QGS projects will be processed, you can:

- Mount a file to `/preseed_services.txt` which contains the services names, one per line. For example:
  -  `subdir/projectname` for a QGS file located in `qgs-resources/subdir/projectname.qgs`
  - `pg/schema/projectname` for a QGS project located in a DB in schema `schema` and named `projectname`
- Mount the `qgs-resources` dir (or whichever directory is mounted to `/data` for `qwc-qgis-server`) to `/data`, which will be then searches for projects (ending which `$QGS_EXT`).

The following environment variables can be set:

| Name                 | Default     | Description                                                                      |
|----------------------|-------------|----------------------------------------------------------------------------------|
| `CRON_SCHEDULE`      | `0 3 * * *` | Interval at which the pre-seeding script is run. Default: every day at 03:00.    |
| `EXECUTE_ON_STARTUP` | `0`         | Whether to run the script when the container starts.                             |
| `QGS_EXT`            | `.qgs`      | The QGS project extension to look for (`.qgs` or `.qgz`).                        |
| `FCGI_INSTANCES`     | `10`        | The number of FCGI instances (i.e. the number if simultaneous requests to send). |
| `SLEEP_INTERVAL`     | `1`         | The sleep interval in seconds between sending requests.                          |

*Note*: You should set `FCGI_MIN_PROCESSES` equals to `FCGI_MAX_PROCESSES` in the `qwc-qgis-server` container configuration
and `FCGI_INSTANCES` to the same number in the `qwc-qgs-cache-preseed` container configuration.
