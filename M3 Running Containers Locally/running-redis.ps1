# first follow instructions at https://docs.docker.com/install/ to install docker

# run a new redis container
docker run -d -p 6379:6379 --name redis1 redis

# see that this container is running
docker ps

# view the log output for the container
# (should see "ready to accept connections")
docker logs redis1

# see the images we have on our computer
docker image ls

# run an interactive shell
docker exec -it redis1 sh

# some commands to try inside the shell:
ls -al # view contents of the container file system
redis-cli # start the redis CLI
ping # should respond with 'pong'
set name mark # set a value in the cache
get name # should respond with 'mark'
incr counter # increment (and create) a new counte
incr counter # increment it again
get counter # should respond with '2'
exit # exit from the redis CLI
exit # exit from the interactive shell

# run a second redis container, linked to the first and open an interactive shell
docker run -it --rm --link redis1:redis --name client1 redis sh

# some commands to try inside the shell
redis-cli -h redis # start the redis CLI but connect to the other container
get name # should respond with 'mark'
get counter # should respond with '2'
exit # exit from the redis CLI
exit # exit from the interactive shell

# observe that the second redis container is no longer running
docker ps

# stop the first redis container
docker stop redis1

# see all containers, even stopped ones (will only see redis1)
docker ps -a

# delete the docker redis container
docker rm redis1

# delete the redis image
docker image rm redis