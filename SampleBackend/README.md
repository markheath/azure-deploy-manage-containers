Simple ASP.NET Core web api deployable as docker container

To build and run as a container
```
$ docker build -t samplebackend .
$ docker run -d -p 8081:80 --name backend samplebackend
```