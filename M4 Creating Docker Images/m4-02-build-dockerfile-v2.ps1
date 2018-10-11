# build our docker image and tag it v2
docker build -t samplewebapp:v2 -f multi-stage.Dockerfile .

# run our image
docker run -d -p 8080:80 samplewebapp:v2 --name myappv2

# test it
http://localhost:8080

# delete the container v2
docker rm -f myapp