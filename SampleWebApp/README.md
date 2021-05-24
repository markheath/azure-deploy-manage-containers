Simple ASP.NET Core app deployable as docker container with some diagnostic information

To run this application in a Docker container (using a multi-stage Docker file)
You need to be in the SampleWebApp folder to run these commands. 

```powershell
$ docker build -t samplewebapp .
# docker build -t -f multi-stage.Dockerfile .
$ docker run -d -p 8080:80 -e TestSetting=FromDocker -e TestFileLocation=/home/message.txt --name myapp samplewebapp
```

To see it running, visit `http://localhost:8080`.

Kill the container with

```
$ docker rm -f myapp
```

To build a Windows Docker image (compatible with windows 2019 server build 2004). You need to switch Docker Desktop to Windows mode to do this.
```
$ docker build -t samplewebapp:nano -f win.Dockerfile .
$ docker run -d -p 8080:80 -e TestSetting=Win2004 -e TestFileLocation=/home/message.txt --name myapp samplewebapp:nano
```