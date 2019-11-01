# you need to be in the current folder of SampleWebApp to run this

# before we start, we should have built the sample web app with
# n.b. you need the ASP.NET SDK installed locally to run this
dotnet publish -c Release -o out

# build a docker image from the dockerfile
docker build -t samplewebapp:basic -f basic.Dockerfile .

# see the images we have
docker image ls 

# run the image
docker run -d -p 8080:80 --name myapp samplewebapp:basic

# test it is working:
http://localhost:8080

# delete the container
docker rm -f myapp