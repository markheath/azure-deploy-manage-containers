Simple ASP.NET Core app deployable as docker container with some diagnostic information

To run as docker
```
$ docker build -t samplewebapp .
$ docker run -d -p 8080:80 -e TestSetting=FromDocker TestFileLocation=/home/message.txt --name myapp samplewebapp
```