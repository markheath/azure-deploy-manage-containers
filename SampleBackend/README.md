Simple ASP.NET Core web api deployable as docker container

To build and run as a container
```
$ docker build -t samplebackend .
$ docker run -d -p 8081:80 --name backend samplebackend
```

To test: http://localhost:8081/api/values


To build a Windows Docker image (compatible with windows 2019 server build 2004). You need to switch Docker Desktop to Windows mode to do this.
```
$ docker build -t samplebackend:nano -f win.Dockerfile .
$ docker run -d -p 8081:80 samplebackend:nano
```