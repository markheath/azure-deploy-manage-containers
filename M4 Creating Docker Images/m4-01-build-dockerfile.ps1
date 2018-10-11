# before we start, we should have built the sample web app with
dotnet publish -c Release -o out

# build a docker image from the dockerfile
docker build -t samplewebapp -f basic.Dockerfile .

# see the images we have
docker image ls 

# run the image
docker run -d -p 8080:80 samplewebapp –name myapp

# test it is working:
http://localhost:8080

# delete the container
docker rm -f myapp