#!/bin/bash

# Purpose of this script is to create the SQL Server wehre the queries will be executed on.

# Build & Run the docker image:
sudo docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=SqlServer1" \
   -p 1433:1433 --name sql1 -h sql1 \
   -d mcr.microsoft.com/mssql/server:2019-latest

# copy the SQL Scripts to the container and then execute them in order to generate the star schema:
docker cp ../sql/ sql1:/
docker cp ./create_database.sh sql1:/

# execute the scripts copied from the previous steps by connecting to the container and executing the commands one by one.
docker exec sql1 pwd
docker exec -u root sql1 "chmod +x ./create_database.sh" 

 docker exec sql1 "./create_database.sh"