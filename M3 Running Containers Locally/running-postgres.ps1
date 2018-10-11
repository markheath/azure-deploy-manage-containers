# start a new container running postgres with an attached volume
docker run -d -p 5432:5432 -v postgres-data:/var/lib/postgresql/data `
--name postgres1 postgres

# run an interactive shell against our container
docker exec -it postgres1 sh

# inside the shell:
createdb -U postgres mydb # create a new db
psql -U postgres mydb # connect to the db with the postgres CLI tool
CREATE TABLE people (id int, name varchar(80)); # create a table
INSERT INTO people (id,name) VALUES (2, 'Steph'); # insert a row into the table
\q # exit the postgres CLI
exit # exit the interactive shell

# stop and delete the postgres1 container
docker rm -f postgres1

# check that the postgres-data volume still exists:
docker volume ls

# start a brand new container connected to the same volume
docker run -d -p 5432:5432 -v postgres-data:/var/lib/postgresql/data `
--name postgres2 postgres

# run an interactive shell against this container
docker exec -it postgres2 sh

# inside the shell
psql -U postgres mydb # connect to the db with the postgres CLI tool
SELECT * FROM people; # check that the data we entered previously is still there
\q # exit the postgres CLI
exit # exit the interactive shell

# stop delete the second container
docker rm -f postgres2

# delete the volume containing the database
docker volume rm postgres-data