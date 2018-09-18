Simple ASP.NET Core app deployable as docker container with some diagnostic information

Todo:
[ ] Write to file
[ ] POST to web API
[ ] Layout (use bootstrap and libman)

To run as docker
```
$ docker build -t SampleWebApp .
$ docker run -d -p 8080:80 -e TestSetting=FromDocker --name myapp SampleWebApp
```