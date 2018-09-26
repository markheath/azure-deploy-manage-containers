Simple ASP.NET Core app deployable as docker container with some diagnostic information

To run as docker
```
$ docker build -t samplewebapp .
$ docker run -d -p 8080:80 -e TestSetting=FromDocker TestFileLocation=/home/message.txt --name myapp samplewebapp
```

For a windows build (compatible with windows 2016 server build 1709)
```
$ docker build -t samplewebapp:win1709 -f Dockerfile.win .
$ docker run -d -p 8080:80 -e TestSetting=Win1709 TestFileLocation=/home/message.txt --name myapp samplewebapp:win1709
```