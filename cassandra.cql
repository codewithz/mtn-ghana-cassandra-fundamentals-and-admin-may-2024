'' On Desktop there is a folder by name Cassandra-Fundamentals 

Inside it cluster-setup folder

Create a folder in single-dc by name apache 

in that folder create a file docker-compose.yml 

and post the following content in the docker-compose.yml file


version: '3'
services:
  n1:
    image: cassandra:5
    networks:
      - cluster
  n2:
    image: cassandra:5
    networks:
      - cluster
    environment:
      - CASSANDRA_SEEDS=n1
    depends_on:
      - n1
  n3:
    image: cassandra:5
    networks:
      - cluster
    environment:
      - CASSANDRA_SEEDS=n1
    depends_on:
      - n1
networks:
  cluster:

//-------------------------------------------------------------------------------------------------------------







To deploy a single Cassandra node to this docker host, run this command:

  cd single-dc\apache
  docker-compose up -d n1

Check the status of the cluster by running:

  docker-compose exec n1 nodetool status

Keep checking this until the status is "UN" (Up & Normal)

To add a second node to the Cassandra cluster, run this command:

	docker-compose up -d n2

Check the status of the cluster by running:

  docker-compose exec n1 nodetool status

Keep checking this until the status of all nodes is "UN" (Up & Normal)

To add a third node to the cluster, run a command similar to the last:

  docker-compose up -d n3

Check again with "nodetool status" until all 3 nodes are "up" and "normal"

You can view the virtual node token allocations by running:

	docker-compose exec n1 nodetool ring

You can log into one of the containers and view the configuration file with:

	docker-compose exec n1 more /etc/cassandra/cassandra.yaml

When you're done, stop and remove the Cassandra containers with:


//--------------------------------------------------------
Multi DatCenter Cluster- Cassandra


To deploy a single Cassandra node, specifying a datacenter and rack:

  cd multi-dc
  docker-compose up -d n1

Check the status of the cluster by running:

  docker-compose exec n1 nodetool status

Keep checking this until the status is "UN" (Up & Normal)

To add a second node in a different rack:

	docker-compose up -d n2

Check the status of the cluster by running:

  docker-compose exec n1 nodetool status

Keep checking this until the status of all nodes is "UN" (Up & Normal)

To add a third node in a different datacenter:

	 docker-compose up -d n3

Check again with "nodetool status" until all 3 nodes are "up" and "normal"

To view the configuration file where the datacenter and rack info is stored:

	docker-compose exec n3 bash
	more /etc/cassandra/cassandra-rackdc.properties
	exit

You can run 'nodetool status' and 'nodetool ring' as before

When you're done, stop and remove the containers as before

   docker-compose down
 //------------------------ output -----------------------------------------------------  
  Datacenter: DC1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  172.18.0.2  138.2 KiB  256          63.1%             afabf7c2-99db-48f2-8d06-1e1b41df8de0  RAC1
UN  172.18.0.3  119.03 KiB  256          68.4%             32421e38-cc9f-4e61-afc5-acf52eaf56c5  RAC2
Datacenter: DC2
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  172.18.0.4  70.91 KiB  256          68.5%             1964a4f4-8475-456c-9939-b377fe6d4582  RAC1 



------------- Replication Stratergy--------------

Create a three node cluster:

   cd single-dc
   docker-compose up -d

 This may take a while to start-up all three nodes.  You can watch the logs of one of the nodes:

    docker-compose logs -f n3
    (Look for "Starting listening for CQL clients", then Ctrl-C to exit)

Run cqlsh with:

    docker-compose exec n1 cqlsh




Create a keyspace by entering this CQL at the cqlsh> prompt:

    create keyspace codewithz with replication = {'class':'SimpleStrategy', 'replication_factor':3};
    exit

Examine the token allocations for this keyspace by exiting cqlsh and running a new nodetool command:

    docker-compose exec n1 nodetool describering codewithz

Run nodetool status, supplying the name of the keyspace, and notice that each node "owns" 100% of the data:

    docker-compose exec n1 nodetool status codewithz

Now run cqlsh again and drop and recreate the keyspace with a different replication factor:

    docker-compose exec n1 cqlsh

    drop keyspace codewithz;
    create keyspace codewithz with replication = {'class':'SimpleStrategy', 'replication_factor':1};
    exit

Run nodetool status again and notice that now each node only "owns" about a third of the data:

    docker-compose exec n1 nodetool status codewithz

Run nodetool describering again and notice that each token range is only allocated one endpoint:

    docker-compose exec n1 nodetool describering codewithz

Take one of the end_token values from these results and find it in the nodetool ring output:

    docker-compose exec n1 nodetool ring | grep [end_token]

(where [end_token] is an end_token value taken from the results of nodetool describering)
Note that the IP address is same as the end_point found in the "nodetool describering" output

Stop and remove each of your docker containers:

    docker-compose down
    
    
    
    
Create a multi-DC cluster as described in module 1, placing nodes in the following data centers and racks:

    cd multi-dc
    docker compose up -d

This may take a while to start-up all four nodes.  You can watch the logs of one of the nodes:

    docker-compose logs -f n4
    (Look for "Starting listening for CQL clients", then Ctrl-C to exit)

Run "nodetool status" to see the nodes distributed between datacenters and racks

    docker-compose exec n1 nodetool status

Run cqlsh with:

    docker-compose exec n1 cqlsh

Create the codewithz keyspace again, but this time with a different replication strategy:

    create keyspace codewithz with replication = {'class':'NetworkTopologyStrategy','DC1':2,'DC2':1};
    exit

Exit cqlsh and run describering again, noting that the endpoints obey the keyspace data center parameters above

    docker-compose exec n1 nodetool describering codewithz

Run nodetool status and note that the one node in DC2 owns all the data, as does the one node in RAC2 of DC1:

    docker-compose exec n1 nodetool status codewithz

Stop and remove all four docker containers:

    docker-compose down

-----

Changes in .wslconfig

[wsl2]
memory=12G

-------------------- For Consistency Work----------------------


Create a three node cluster:

   cd single-dc
   docker-compose up -d

This may take a while to start-up all three nodes.  You can watch the logs of one of the nodes:

   docker-compose logs -f n3
   (Look for "Starting listening for CQL clients", then Ctrl-C to exit)

Run cqlsh with:

    docker-compose exec n1 cqlsh

Create a keyspace and "use" it by entering this CQL at the cqlsh> prompt:

    create keyspace codewithz with replication = {'class':'SimpleStrategy', 'replication_factor':3};
    use codewithz;

Create a simple, one column table in this keyspace:

    create table courses (id varchar primary key);

Check the current consistency level in cqlsh by running this command and examining the output:

    consistency;

Insert a row into the courses table and see it succeed at this concurrency level:

    insert into courses (id) values ('cassandra-developers');

Set the consistency level to "quorum" and successfully insert another row into the table:

    consistency quorum;
    insert into courses (id) values ('react-big-picture');

Set the consistency level to "all", turn on tracing, and insert a third row:

    consistency all;
    tracing on;
    insert into courses (id) values ('nodejs-big-picture');
    exit

Exit cqlsh and take one of the cassandra nodes offline by stopping the docker container:

    docker-compose stop n3

Run cqlsh again, set the consistency level to "all" and try to insert another row into the courses table:

    docker-compose exec n1 cqlsh

    use codewithz;
    consistency all;
    insert into courses (id) values ('advanced-python');

Set the consistency to "quorum" and try the same insert again:

    consistency quorum;
    insert into courses (id) values ('advanced-python');

Select one of the inserted rows back from the courses table:

    select * from courses where id = 'cassandra-developers';

Set the consistency level to "all" and attempt to repeat the select statement:

    consistency all;
    select * from courses where id = 'cassandra-developers';
    exit

 Exit cqlsh and bring the previously downed node back online:

     docker-compose start n3

 Run cqlsh, set the consistency level to "all" and retry the select statement:

     docker-compose exec n1 cqlsh

     consistency all;
     use codewithz;
     select * from courses where id = 'cassandra-developers';
     exit

 Stop and remove each of your docker containers:

    docker-compose down

----- -------------------------- ********************************* --------------------------------------------

Create a multi-DC cluster as described in module 1, placing nodes in the following data centers and racks:

    cd multi-dc
    docker compose up -d

This may take a while to start-up all four nodes.  You can watch the logs of one of the nodes:

    docker-compose logs -f n4
    (Look for "Starting listening for CQL clients", then Ctrl-C to exit)

Run cqlsh with:

    docker-compose exec n1 cqlsh

Create the codewithz keyspace with NetworkTopologyStrategy, and create the courses table as before:

    create keyspace codewithz with replication = {'class':'NetworkTopologyStrategy', 'DC1':3,'DC2':1};
    use codewithz;
    create table courses (id varchar primary key);

Set the consistency level to "local_one" and insert a row into the table:

    consistency local_one;
    insert into courses (id) values ('cassandra-developers');
    exit

Exit cqlsh and take down the one node in DC2:

    docker-compose stop n4

Run nodetool status and verify that Cassandra treats this node as "down"

    docker-compose exec n1 nodetool status

Run cqlsh, set the consistency to "each_quorum" and try the insert again:

    docker-compose exec n1 cqlsh

    use codewithz;
    consistency each_quorum;
    insert into courses (id) values ('nodejs-big-picture');

Set the consistency to "local_quorum" and successfully insert the row:

    consistency local_quorum;
    insert into courses (id) values ('nodejs-big-picture');
    exit

Stop and remove all four docker containers:

    docker-compose down


//----------- Table Properties -----------------

Caching (keys, rows_per_partition): Caching is crucial for improving read performance in Cassandra.
Caching keys and rows per partition can significantly reduce latency by storing frequently accessed data in memory.

read_repair_chance: This parameter determines the probability that Cassandra will perform read repairs during read operations.
It helps maintain data consistency by ensuring that inconsistent data between replicas is repaired over time.

dclocal_read_repair_chance: Similar to read_repair_chance, but specifically for repairs within the local data center.
It's useful for reducing cross-data center traffic for read repairs.

default_time_to_live: Sets the default time to live (TTL) for data stored in Cassandra. 
Data expires and is automatically deleted after the specified TTL, which is useful for managing data retention policies.

gc_grace_seconds: Specifies the grace period for tombstones (deleted data) before Cassandra permanently removes them during compaction.
It helps prevent deleted data from resurfacing due to network delays or node failures.

bloom_filter_fp_chance: Controls the probability of false positives in Bloom filters,
which are used to quickly determine if a row may exist in a partition during read operations. Adjusting this parameter affects memory usage and query performance.

compaction: Configures how Cassandra merges and cleans up data files to optimize storage and performance. 
It includes options like size-tiered, leveled, and date-tiered compaction strategies.

compression: Specifies the compression algorithm used for data storage on disk. 
Compression reduces storage space and can improve read/write performance, but it may increase CPU usage.

min/max_index_interval: These parameters control the frequency of index sampling, affecting query performance. 
Smaller intervals result in more accurate indexes but require more memory.

memtable_flush_period_in_ms: Sets the frequency at which memtables (in-memory data structures) are flushed to disk. 
Adjusting this parameter impacts write throughput and latency.

populate_io_cache_on_flush: Determines whether Cassandra populates the operating system's disk cache with flushed data.
It can improve read performance by caching frequently accessed data in memory.

speculative_retry: Enables Cassandra to execute speculative retries for read operations when a replica takes longer than expected to respond. 
It helps improve read latency by sending additional requests to other replicas.


//--------------- CQL Commands--------------------

Start up a single-node of Cassandra with:

    docker-compose up -d

Run cqlsh with:

    docker-compose exec n1 cqlsh

Create a keyspace with:

    create keyspace codewithz with replication = {'class':'SimpleStrategy', 'replication_factor':1};

Create a table in this keyspace with:

    use codewithz;
    create table courses (id varchar primary key);

Optionally attempt to create the table again with:

    create table if not exists courses (id varchar primary key);

(and note that you will not get an error as long as the 'if not exists' is present)

Add a few columns to the courses table with:

    alter table courses add duration int;
    alter table courses add released timestamp;
    alter table courses add author varchar;

Add a comment to the table with:

    alter table courses with comment = 'A table of courses';

View the complete table and all its default properties with:

    desc table courses;

Drop and recreate a more complete courses table with:

    drop table courses;
    create table courses (
        id varchar primary key,
        name varchar,
        author varchar,
        audience int,
        duration int,
        cc boolean,
        released timestamp
        ) with comment = 'A table of courses';

(Note that when entering the lines as above cqlsh will automatically detect a multi-line CQL statement)

View the completed table one last time:

    desc table courses;

Exit cqlsh:

    exit
    
    Link for courses and users file  --> https://we.tl/t-qAdzCbGrC3
    

//------------------------------------------------------------------

Load course data by running a series of CQL commands from an external file


PS C:\Users\student\Desktop\Cassandra-Fundamentals\3-cql-basics> Get-Content .\scripts\courses.cql | docker-compose exec -T n1 cqlsh
time="2024-05-15T14:29:41+02:00" level=warning msg="C:\\Users\\student\\Desktop\\Cassandra-Fundamentals\\3-cql-basics\\docker-compose.yml: `version` is obsolete"
PS C:\Users\student\Desktop\Cassandra-Fundamentals\3-cql-basics> Get-Content .\scripts\users.cql | docker-compose exec -T n1 cqlsh
time="2024-05-15T14:30:54+02:00" level=warning msg="C:\\Users\\student\\Desktop\\Cassandra-Fundamentals\\3-cql-basics\\docker-compose.yml: `version` is obsolete"
PS C:\Users\student\Desktop\Cassandra-Fundamentals\3-cql-basics>

//-------------------------------------------------------------------------------------------------------------------------------------------------

    cat scripts/courses.cql | docker-compose exec -T n1 cqlsh
    
    //--------------------------------------------------------------------------
    
    

Run cqlsh with:

    docker-compose exec n1 cqlsh

Verify that the CQL commands in the file were indeed executed:

    use codewithz;
    desc tables;
    select * from courses;
    
    
    
  Verify that the CQL commands in the file were indeed executed:

    use codewithz;
    desc tables;
    select * from courses;

exp(The 'desc tables' should show a single 'courses' table, and the 'select' statement should show 5 rows of sample data.)

The 'expand' cqlsh command will display the query results in a 'one column per line' format:

    expand on;
    select * from courses;
    expand off;

-----

You can display the time a piece of data was written with the 'writetime' function:

    select id, cc, writetime(cc) from courses where id = 'advanced-javascript';

We can update this cc column with an 'update' statement:

    update courses set cc = true where id = 'advanced-javascript';

Now re-run the select statement containing the 'writetime' function and notice that the time has changed.
You can prove to yourself that this write time is stored on a per column basis by selecting this for a different column:

    select id, name, writetime(name) from courses where id = 'advanced-javascript';

Note that this writetime value is the same as the one returned by our first 'cc' query.

-----

Cassandra also provides a function for returning the token associated with a partition key:

    select id, token(id) from courses;

-----

If you try to select from a column other than the primary key, you'll get an error:

    select * from courses where author = 'Cory House';

(We'll show how to do this in a later module.)

-----

Let's create a users table:

    create table users (
        id varchar primary key,
        first_name varchar,
        last_name varchar,
        email varchar,
        password varchar
        ) with comment = 'A table of users';

Then we'll insert and "upsert" two rows of data:

    insert into users (id, first_name, last_name) values ('john-doe', 'John', 'Doe');
    update users set first_name = 'Jane', last_name = 'Doe' where id = 'jane-doe';
    select * from users;

(Note that the net effect of the insert and update are the same.)

Now we'll add a new 'reset_token' column to this table, and add a value to this column with a TTL:

    alter table users add reset_token varchar;
    update users using ttl 120 set reset_token = 'abc123' where id = 'john-doe';

We can retrieve the time remaining for a ttl with the 'ttl' query function:


cqlsh:codewithz> select * from users;

 id       | email | first_name | last_name | password
----------+-------+------------+-----------+----------
 john-doe |  null |       John |       Doe |     null

(1 rows)
cqlsh:codewithz>   update users set first_name = 'Jane', last_name = 'Doe' where id = 'jane-doe';
cqlsh:codewithz> select * from users;

 id       | email | first_name | last_name | password
----------+-------+------------+-----------+----------
 jane-doe |  null |       Jane |       Doe |     null
 john-doe |  null |       John |       Doe |     null

(2 rows)
cqlsh:codewithz>  alter table users add reset_token varchar;
cqlsh:codewithz>   update users using ttl 600 set reset_token = 'abc123' where id = 'john-doe';
cqlsh:codewithz>  alter table users add reset_token varchar;
InvalidRequest: Error from server: code=2200 [Invalid query] message="Invalid column name reset_token because it conflicts with an existing column"
cqlsh:codewithz> select * from users;

 id       | email | first_name | last_name | password | reset_token
----------+-------+------------+-----------+----------+-------------
 jane-doe |  null |       Jane |       Doe |     null |        null
 john-doe |  null |       John |       Doe |     null |      abc123

(2 rows)
cqlsh:codewithz> tracing on;
Now Tracing is enabled
cqlsh:codewithz> select * from users where id='john-doe';

 id       | email | first_name | last_name | password | reset_token
----------+-------+------------+-----------+----------+-------------
 john-doe |  null |       John |       Doe |     null |      abc123

(1 rows)

Tracing session: fca9c950-12b9-11ef-b352-cf2bb105377c

 activity                                                                       | timestamp                  | source     | source_elapsed | client
--------------------------------------------------------------------------------+----------------------------+------------+----------------+-----------
                                                             Execute CQL3 query | 2024-05-15 12:52:28.922000 | 172.21.0.2 |              0 | 127.0.0.1
 Parsing select * from users where id='john-doe'; [Native-Transport-Requests-1] | 2024-05-15 12:52:28.939000 | 172.21.0.2 |          18976 | 127.0.0.1
                              Preparing statement [Native-Transport-Requests-1] | 2024-05-15 12:52:28.942000 | 172.21.0.2 |          21682 | 127.0.0.1
                        Executing single-partition query on users [ReadStage-2] | 2024-05-15 12:52:28.948000 | 172.21.0.2 |          27705 | 127.0.0.1
                                     Acquiring sstable references [ReadStage-2] | 2024-05-15 12:52:28.948000 | 172.21.0.2 |          27973 | 127.0.0.1
                                        Merging memtable contents [ReadStage-2] | 2024-05-15 12:52:28.949000 | 172.21.0.2 |          28380 | 127.0.0.1
               Partition index with 0 entries found for sstable 1 [ReadStage-2] | 2024-05-15 12:52:28.952000 | 172.21.0.2 |          32066 | 127.0.0.1
                           Read 1 live rows and 0 tombstone cells [ReadStage-2] | 2024-05-15 12:52:29.519000 | 172.21.0.2 |         598252 | 127.0.0.1
                                                               Request complete | 2024-05-15 12:52:29.522002 | 172.21.0.2 |         600002 | 127.0.0.1


cqlsh:codewithz> select ttl(reset_token) from users where id='john-doe';

 ttl(reset_token)
------------------
              502

(1 rows)

Tracing session: 13c99610-12ba-11ef-b352-cf2bb105377c

 activity                                                                                      | timestamp                  | source     | source_elapsed | client
-----------------------------------------------------------------------------------------------+----------------------------+------------+----------------+-----------
                                                                            Execute CQL3 query | 2024-05-15 12:53:07.697000 | 172.21.0.2 |              0 | 127.0.0.1
 Parsing select ttl(reset_token) from users where id='john-doe'; [Native-Transport-Requests-1] | 2024-05-15 12:53:07.700000 | 172.21.0.2 |           3269 | 127.0.0.1
                                             Preparing statement [Native-Transport-Requests-1] | 2024-05-15 12:53:07.701000 | 172.21.0.2 |           4672 | 127.0.0.1
                                       Executing single-partition query on users [ReadStage-2] | 2024-05-15 12:53:07.704000 | 172.21.0.2 |           7416 | 127.0.0.1
                                                    Acquiring sstable references [ReadStage-2] | 2024-05-15 12:53:07.704000 | 172.21.0.2 |           7552 | 127.0.0.1
                                                       Merging memtable contents [ReadStage-2] | 2024-05-15 12:53:07.704000 | 172.21.0.2 |           7668 | 127.0.0.1
                                                     Key cache hit for sstable 1 [ReadStage-2] | 2024-05-15 12:53:07.705000 | 172.21.0.2 |           8641 | 127.0.0.1
                                          Read 1 live rows and 0 tombstone cells [ReadStage-2] | 2024-05-15 12:53:07.707000 | 172.21.0.2 |          10121 | 127.0.0.1
                                                                              Request complete | 2024-05-15 12:53:07.709330 | 172.21.0.2 |          12330 | 127.0.0.1


cqlsh:codewithz>

    select ttl(reset_token) from users where id = 'john-doe';
    


//-------------------------------------------------------------------------

Create a ratings table with two counter columns:

    create table ratings (
        course_id varchar primary key,
        ratings_count counter,
        ratings_total counter
        ) with comment = 'A table of course ratings';

Now let's increment both counter columns to represent receiving a new course rating of 4:

    update ratings set ratings_count = ratings_count + 1, ratings_total = ratings_total + 4 where course_id = 'nodejs-big-picture';
    select * from ratings;

(The select should show the data we just upserted.)

Now let's add a second course rating of 3:

    update ratings set ratings_count = ratings_count + 1, ratings_total = ratings_total + 3 where course_id = 'nodejs-big-picture';
    select * from ratings;
    exit

This should show the new values of "2" and "7" for ratings_count and ratings_total respectively.

Drop and re-create "ratings" to use with the "avg" aggregate function

    drop table ratings;

    create table ratings (
        course_id varchar,
        user_id varchar,
        rating int,
        primary key (course_id, user_id)
    );

Insert a few sample ratings

    insert into ratings (course_id, user_id, rating) values ('cassandra-developers', 'user1', 4);
    insert into ratings (course_id, user_id, rating) values ('cassandra-developers', 'user2', 5);
    insert into ratings (course_id, user_id, rating) values ('cassandra-developers', 'user3', 4);
    insert into ratings (course_id, user_Id, rating) values ('advanced-python', 'user1', 5);

You can select the average for a single course (across users):

    select course_id, avg(rating) from ratings where course_id = 'cassandra-developers';
    select course_id, avg(rating) from ratings where course_id = 'advanced-python';

However, you can't apply aggregate functions across partition keys:

    select course_id, avg(rating) from courses;  // incorrect results

Stop and remove the docker container:

    docker-compose down
    
    
   //--------------------------------------------------------------------------------- 
    
  cqlsh> use codewithz;
cqlsh:codewithz>     create table ratings (
        course_id varchar primary key,
        ratings_count counter,
        ratings_total counter
        ) with comment = 'A table of course ratings';
cqlsh:codewithz>  update ratings set ratings_count = ratings_count + 1, ratings_total = ratings_total + 4 where course_id = 'nodejs-big-picture';
cqlsh:codewithz> select * from ratings;

 course_id          | ratings_count | ratings_total
--------------------+---------------+---------------
 nodejs-big-picture |             1 |             4

(1 rows)
cqlsh:codewithz>  update ratings set ratings_count = ratings_count + 1, ratings_total = ratings_total + 3 where course_id = 'nodejs-big-picture';
cqlsh:codewithz> select * from ratings;

 course_id          | ratings_count | ratings_total
--------------------+---------------+---------------
 nodejs-big-picture |             2 |             7

(1 rows)
cqlsh:codewithz> drop table ratings;
cqlsh:codewithz>     create table ratings (
        course_id varchar,
        user_id varchar,
        rating int,
        primary key (course_id, user_id)
    );
cqlsh:codewithz>  insert into ratings (course_id, user_id, rating) values ('cassandra-developers', 'user1', 4);
    insert into ratings (course_id, user_id, rating) values ('cassandra-developers', 'user2', 5);
    insert into ratings (course_id, user_id, rating) values ('cassandra-developers', 'user3', 4);
    insert into ratings (course_id, user_Id, rating) values ('advanced-python', 'user1', 5);
cqlsh:codewithz> select * from ratings;

 course_id            | user_id | rating
----------------------+---------+--------
      advanced-python |   user1 |      5
 cassandra-developers |   user1 |      4
 cassandra-developers |   user2 |      5
 cassandra-developers |   user3 |      4

(4 rows)
cqlsh:codewithz>  select course_id, avg(rating) from ratings where course_id = 'cassandra-developers';

 course_id            | system.avg(rating)
----------------------+--------------------
 cassandra-developers |                  4

(1 rows)
cqlsh:codewithz>  select course_id, avg(rating) from ratings where course_id = 'advanced-python';

 course_id       | system.avg(rating)
-----------------+--------------------
 advanced-python |                  5

(1 rows)
cqlsh:codewithz>  select course_id, avg(rating) from courses;
InvalidRequest: Error from server: code=2200 [Invalid query] message="Undefined column name course_id"
cqlsh:codewithz>  select course_id, avg(rating) from ratings;

 course_id       | system.avg(rating)
-----------------+--------------------
 advanced-python |                  4

(1 rows)

Warnings :
Aggregation query used without partition key

cqlsh:codewithz>


//------------------------------------------------------------

Start up a single-node of Cassandra with:

    docker-compose up -d

Verify it's "up" and "normal" with "nodetool status"

    docker-compose exec n1 nodetool status

Load course data by running a series of CQL commands from an external file

    cat scripts/m3/courses.cql | docker-compose exec -T n1 cqlsh

Run cqlsh with:

    docker-compose exec n1 cqlsh

Display the courses table schema and notice it's the seven columns from the end of the last module

    use codewithz;
    desc table courses;

Select data from this table and see the five sample courses we loaded from our file

    select * from courses;
---------------------------------------------------------------------------------------------
Drop this table and create a new one to hold both course and module data

    drop table courses;
    create table courses (
        id varchar,
        name varchar,
        author varchar,
        audience int,
        duration int,
        cc boolean,
        released timestamp,
        module_id int,
        module_name varchar,
        module_duration int,
        primary key (id, module_id)
    ) with comment = 'A table of courses and modules';

Insert data for the course, plus the first two modules

    insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
    values ('nodejs-big-picture','Node.js: The Big Picture','Paul O''Fallon', 1, 3240, true, '2019-06-03',1,'Course Overview',70);

    insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
    values ('nodejs-big-picture','Node.js: The Big Picture','Paul O''Fallon', 1, 3240, true, '2019-06-03',2,'Considering Node.js',900);

Select the data we just inserted

    select * from courses;
    select * from courses where id = 'nodejs-big-picture';

Now we can include both id and module_id in our where clause

    select * from courses where id = 'nodejs-big-picture' and module_id = 2;

We can't select by just module, unless we enable 'ALLOW FILTERING'

    select * from courses where module_id = 2;                  // fails
    select * from courses where module_id = 2 allow filtering;   // succeeds

Now insert the remaining modules for the course

    insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
    values ('nodejs-big-picture','Node.js: The Big Picture','Paul O''Fallon', 1, 3240, true, '2019-06-03', 3, 'Thinking Asynchronously', 1304);

    insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
    values ('nodejs-big-picture','Node.js: The Big Picture','Paul O''Fallon', 1, 3240, true, '2019-06-03', 4, 'Defining an Application and Managing Dependencies', 525);

    insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
    values ('nodejs-big-picture','Node.js: The Big Picture','Paul O''Fallon', 1, 3240, true, '2019-06-03', 5, 'Assembling a Development Toolset', 489);

We can also use module_id as part of an "in" clause

    select * from courses where id = 'nodejs-big-picture' and module_id in (2,3,4);

And we can order by module_id

    select * from courses where id = 'nodejs-big-picture' order by module_id desc;

We can "select distinct" just the id, but not the id and course name:

    select distinct id from courses;         // succeeds
    select distinct id, name from courses;   // fails

Shutdown our Cassandra instance

    exit
    docker-compose down

-----


------------------ Static Columns------------------------


Launch our one Cassandra node and (when it's ready) load our sample course data

    docker-compose up -d
    docker-compose exec n1 nodetool status
    cat scripts/m3/courses.cql | docker-compose exec -T n1 cqlsh

Run cqlsh with:

    docker-compose exec n1 cqlsh

From cqlsh, drop and recreate the courses table, using static columns

    use codewithz;
    drop table courses;
    create table courses (
        id varchar,
        name varchar static,
        author varchar static,
        audience int static,
        duration int static,
        cc boolean static,
        released timestamp static,
        module_id int,
        module_name varchar,
        module_duration int,
        primary key (id, module_id)
    ) with comment = 'A table of courses and modules';

Insert just the course data, and select it back

    insert into courses (id, name, author, audience, duration, cc, released)
    values ('nodejs-big-picture','Node.js: The Big Picture','Paul O''Fallon', 1, 3240, true, '2019-06-03');

    select * from courses where id = 'nodejs-big-picture';

Now insert the module data for the first two modules

    insert into courses (id, module_id, module_name, module_duration)
    values ('nodejs-big-picture',1,'Course Overview',70);

    insert into courses (id, module_id, module_name, module_duration)
    values ('nodejs-big-picture',2,'Considering Node.js',900);

Selecting from courses now returns both course and module data in each row

    select * from courses where id = 'nodejs-big-picture';
    select * from courses where id = 'nodejs-big-picture' and module_id = 2;

Insert the third module, but also change the name of the course.  Select all rows to show the course title changed everywhere.

    insert into courses (id, name, module_id, module_name, module_duration)
    values ('nodejs-big-picture', 'The Big Node.js Picture', 3, 'Thinking Asynchronously', 1304);

    select * from courses where id = 'nodejs-big-picture';

Insert the fourth module, and fix the course name

    insert into courses (id, name, module_id, module_name, module_duration)
    values ('nodejs-big-picture', 'Node.js: The Big Picture', 4, 'Defining an Application and Managing Dependencies', 525);

Insert the remaining course module

    insert into courses (id, module_id, module_name, module_duration)
    values ('nodejs-big-picture', 5, 'Assembling a Development Toolset', 489);

The 'in' and 'order by' clauses work the same as before

    select * from courses where id = 'nodejs-big-picture' and module_id in (2,3,4);

    select * from courses where id = 'nodejs-big-picture' order by module_id desc;

Select course info, repeated based on the number of modules in the course

    select id, name, author, audience, duration, cc, released from courses;

Now "select distinct" course info and only get one row back

    select distinct id, name, author, audience, duration, cc, released from courses;

Select just the module information for the course

    select module_id, module_name, module_duration from courses where id = 'nodejs-big-picture';

Exit cqlsh:

    exit

-----   Time Based Data-------------

-----

Launch our one Cassandra node and (when it's ready) load our sample course data

    docker-compose up -d
    docker-compose exec n1 nodetool status
    cat scripts/m4/courses.cql | docker-compose exec -T n1 cqlsh

Run cqlsh with:

    docker-compose exec n1 cqlsh

From cqlsh, create a new table to hold course page views

    use codewithz;
    create table course_page_views (
        course_id varchar,
        view_id timeuuid,
        primary key (course_id, view_id)
    ) with clustering order by (view_id desc);

Insert a row into this table, using "now()" to create a timeuuid with the current date/time.  Include a one year TTL.

    insert into course_page_views (course_id, view_id)
    values ('nodejs-big-picture', now()) using TTL 31536000;

Insert another row into the table with a manually generated v1 UUID (also with a TTL)

    insert into course_page_views (course_id, view_id)
    values ('nodejs-big-picture', bb9807aa-fb68-11e9-8f0b-362b9e155667) using TTL 31536000;

Insert two more rows using "now()"

    insert into course_page_views (course_id, view_id)
    values ('nodejs-big-picture', now()) using TTL 31536000;

    insert into course_page_views (course_id, view_id)
    values ('nodejs-big-picture', now()) using TTL 31536000;

Select the rows, and then use dateOf() to extract the date/time portion of the view_id

    select * from course_page_views;
    select dateOf(view_id) from course_page_views where course_id = 'nodejs-big-picture';

Reverse the date order of the results

    select dateOf(view_id) from course_page_views where course_id = 'nodejs-big-picture' order by view_id asc;

Select only those dates based on Timeuuids that span a 2 day range

    select dateOf(view_id) from course_page_views where course_id = 'nodejs-big-picture'
    and view_id >= maxTimeuuid('2019-10-30 00:00+0000')
    and view_id < minTimeuuid('2019-11-02 00:00+0000');

    // adjust these dates as necessary to match a more current date range

Truncate the table, and add a static column

    truncate course_page_views;
    alter table course_page_views add last_view_id timeuuid static;

Now insert three rows, using "now()" for both Timeuuids (with TTLs)

    insert into course_page_views (course_id, last_view_id, view_id)
    values ('nodejs-big-picture', now(), now()) using TTL 31536000;

    insert into course_page_views (course_id, last_view_id, view_id)
    values ('nodejs-big-picture', now(), now()) using TTL 31536000;

    insert into course_page_views (course_id, last_view_id, view_id)
    values ('nodejs-big-picture', now(), now()) using TTL 31536000;

Selecting all rows shows different view_ids but the same last_view_id for all rows

    select * from course_page_views;

Use 'select distinct' to get just the latest page view for this course

    select distinct course_id, last_view_id from course_page_views;

For just one course, this can also be accomplished with the view_id and a LIMIT clause

    select course_id, view_id from course_page_views where course_id = 'nodejs-big-picture' limit 1;

However, a 'limit' won't work across multiple courses.  Insert multiple views for another course.

    insert into course_page_views (course_id, last_view_id, view_id)
    values ('advanced-javascript', now(), now()) using TTL 31536000;

    insert into course_page_views (course_id, last_view_id, view_id)
    values ('advanced-javascript', now(), now()) using TTL 31536000;

    insert into course_page_views (course_id, last_view_id, view_id)
    values ('advanced-javascript', now(), now()) using TTL 31536000;

Select latest view_id from each course, using the limit clause

    select course_id, view_id from course_page_views where course_id = 'nodejs-big-picture' limit 1;
    select course_id, view_id from course_page_views where course_id = 'advanced-javascript' limit 1;

Retrieve the latest course page view for all courses with 'select distinct' and the static column

    select distinct course_id, last_view_id from course_page_views;

Select all the individual views for each course, one at a time

    select course_id, view_id from course_page_views where course_id = 'nodejs-big-picture';
    select course_id, view_id from course_page_views where course_id = 'advanced-javascript';

Exit cqlsh and shutdown our one Cassandra node

    exit
    docker-compose down

----- Bucketing the Time Series Data ----

Launch our one Cassandra node and (when it's ready) load our sample course data

    docker-compose up -d
    docker-compose exec n1 nodetool status
    cat scripts/m4/courses.cql | docker-compose exec -T n1 cqlsh

Run cqlsh with:

    docker-compose exec n1 cqlsh

From cqlsh, create a new table to hold "bucketed" course page views

    use codewithz;
    create table course_page_views (
        bucket_id varchar,
        course_id varchar,
        last_view_id timeuuid static,
        view_id timeuuid,
        primary key ((bucket_id, course_id), view_id)
    ) with clustering order by (view_id desc);

Insert a few values into different buckets

    insert into course_page_views (bucket_id, course_id, last_view_id, view_id)
    values ('2019-12', 'nodejs-big-picture', now(), now());

    insert into course_page_views (bucket_id, course_id, last_view_id, view_id)
    values ('2020-01', 'nodejs-big-picture', now(), now());

    insert into course_page_views (bucket_id, course_id, last_view_id, view_id)
    values ('2020-01', 'cassandra-developers', now(), now());

Can still select latest course page view for multiple courses,
but we're more constrained this time (bucket and courses required)

    select distinct course_id, last_view_id from course_page_views
    where course_id in ('nodejs-big-picture', 'cassandra-developers') and bucket_id = '2020-01';

Exit cqlsh and shutdown our one Cassandra node

    exit
    docker-compose down
    
  ---------- Complex DataTypes-----
  
  -- Collection Data Types 

List -- Notation Used -- [, , , , ]

Create table footballer
(
    id int PRIMARY KEY,
    name text,
    country text,
    last5scores list<int>
);

Insert into footballer(id,name,country,last5scores) values (1,'C.Ronaldo','Portugal',[2,3,0,2,1]);

update footballer set last5scores=last5scores-[4] where id=1

codewithz@cqlsh:codewithz> update batsmen set last5scores=last5scores-[76] where id=1;
codewithz@cqlsh:codewithz> select * from batsmen;
 id | country | last5scores        | name
----+---------+--------------------+-------------
  1 |   India | [23, 100, 123, 34] | Virat Kohli
(1 rows)
codewithz@cqlsh:codewithz> update batsmen set last5scores=last5scores+[176] where id=1;
codewithz@cqlsh:codewithz> select * from batsmen;
 id | country | last5scores             | name
----+---------+-------------------------+-------------
  1 |   India | [23, 100, 123, 34, 176] | Virat Kohli


  Set - Notation Used {, , , ,}

  Create table passportholder (id int Primary Key, name text, passport set<text>)


  Insert into passportholder(id,name,passport) values (1,'Zartab',{'Z12345','X32145','Z12345'})

  Update passportholder set passport=passport+{'Y34567'} where id=1;

  Map -- Notation --{type:type}

  Create table todo (
      id int Primary Key,
      name text,
      todo map<int,text>
  )


  Insert into todo(id,name,todo) values (1,'Zartab',{1:'Collect Medicine for Mother',2:'Do Laundry',3:'Pay Electicity Bill',4:'Fill up petrol in car'})


  Insert into todo(id,name,todo) values (1,'Zartab',{1:'Collect Medicine for Mother',2:'Do Laundry',3:
'Pay Electicity Bill',4:'Fill up petrol in car'})
                  ... ;
codewithz@cqlsh:codewithz> select * from todod
                  ... ;

codewithz@cqlsh:codewithz> select * from todo;
 id | name   | todo
----+--------+-----------------------------------------------------------------------------------------------------------
  1 | Zartab | {1: 'Collect Medicine for Mother', 2: 'Do Laundry', 3: 'Pay Electicity Bill', 4: 'Fill up petrol in car'}
(1 rows)
codewithz@cqlsh:codewithz> update todo set todo=todo-{4} where id=1;
codewithz@cqlsh:codewithz> select * from todo;
 id | name   | todo
----+--------+-------------------------------------------------------------------------------
  1 | Zartab | {1: 'Collect Medicine for Mother', 2: 'Do Laundry', 3: 'Pay Electicity Bill'}
(1 rows)
codewithz@cqlsh:codewithz> update todo set todo=todo-{2} where id=1;
codewithz@cqlsh:codewithz> select * from todo;
 id | name   | todo
----+--------+--------------------------------------------------------------
  1 | Zartab | {1: 'Collect Medicine for Mother', 3: 'Pay Electicity Bill'}
(1 rows)
codewithz@cqlsh:codewithz> 


------- Complex Data Types --------------

cqlsh:codewithz> create keyspace mtn_complex with replication ={'replication_factor':1,'class':'SimpleStrategy'}
             ... ;
cqlsh:codewithz> use mtn_complex;
cqlsh:mtn_complex> Create table footballer
(
    id int PRIMARY KEY,
    name text,
    country text,
    last5scores list<int>
);
cqlsh:mtn_complex> Insert into batsmen(id,name,country,last5scores) values (1,'C.Ronaldo','Portugal',[2,3,0,2,1]);
InvalidRequest: Error from server: code=2200 [Invalid query] message="unconfigured table batsmen"
cqlsh:mtn_complex> Insert into footballer(id,name,country,last5scores) values (1,'C.Ronaldo','Portugal',[2,3,0,2,1]);
cqlsh:mtn_complex> select * from footballer;

 id | country  | last5scores     | name
----+----------+-----------------+-----------
  1 | Portugal | [2, 3, 0, 2, 1] | C.Ronaldo

(1 rows)
cqlsh:mtn_complex> update footballer set last5scores=last5scores-[4] where id=1
               ... ;
cqlsh:mtn_complex> select * from footballer;

 id | country  | last5scores     | name
----+----------+-----------------+-----------
  1 | Portugal | [2, 3, 0, 2, 1] | C.Ronaldo

(1 rows)
cqlsh:mtn_complex> update footballer set last5scores=last5scores-[1] where id=1 ;
cqlsh:mtn_complex> select * from footballer;

 id | country  | last5scores  | name
----+----------+--------------+-----------
  1 | Portugal | [2, 3, 0, 2] | C.Ronaldo

(1 rows)
cqlsh:mtn_complex> update footballer set last5scores=last5scores+[4] where id=1 ;
cqlsh:mtn_complex> select * from footballer;

 id | country  | last5scores     | name
----+----------+-----------------+-----------
  1 | Portugal | [2, 3, 0, 2, 4] | C.Ronaldo

(1 rows)
cqlsh:mtn_complex> Create table passportholder (id int Primary Key, name text, passport set<text>)
               ... ;
cqlsh:mtn_complex>  Insert into passportholder(id,name,passport) values (1,'Zartab',{'Z12345','X32145','Z12345'});
cqlsh:mtn_complex> select * from passportholder;

 id | name   | passport
----+--------+----------------------
  1 | Zartab | {'X32145', 'Z12345'}

(1 rows)
cqlsh:mtn_complex> Update passportholder set passport=passport+{'Y34567'} where id=1;
cqlsh:mtn_complex> select * from passportholder;

 id | name   | passport
----+--------+--------------------------------
  1 | Zartab | {'X32145', 'Y34567', 'Z12345'}

(1 rows)
cqlsh:mtn_complex>  Create table todo (
      id int Primary Key,
      name text,
      todo map<int,text>
  );
cqlsh:mtn_complex>   Insert into todo(id,name,todo) values (1,'Zartab',{1:'Collect Medicine for Mother',2:'Do Laundry',3:'Pay Electicity Bill',4:'Fill up petrol in car'})
               ... ;
cqlsh:mtn_complex> select * from todo;

 id | name   | todo
----+--------+-----------------------------------------------------------------------------------------------------------
  1 | Zartab | {1: 'Collect Medicine for Mother', 2: 'Do Laundry', 3: 'Pay Electicity Bill', 4: 'Fill up petrol in car'}

(1 rows)
cqlsh:mtn_complex> update todo set todo=todo-{4} where id=1;
cqlsh:mtn_complex> select * from todo;

 id | name   | todo
----+--------+-------------------------------------------------------------------------------
  1 | Zartab | {1: 'Collect Medicine for Mother', 2: 'Do Laundry', 3: 'Pay Electicity Bill'}

(1 rows)
cqlsh:mtn_complex> update todo set todo=todo-{2} where id=1;
cqlsh:mtn_complex> select * from todo;

 id | name   | todo
----+--------+--------------------------------------------------------------
  1 | Zartab | {1: 'Collect Medicine for Mother', 3: 'Pay Electicity Bill'}

(1 rows)
cqlsh:mtn_complex>


//------------ Backup and Restore---------------------

wz@codewithz:~/Desktop/cassandra/apache-cassandra-4.0.12-bin/apache-cassandra-4.0.12$ bin/nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address    Load        Tokens  Owns  Host ID                               Rack 
UN  127.0.0.1  132.68 KiB  16      ?     dbc6ca80-d42c-44e9-8988-cfa0dcdcc22c  rack1

Note: Non-system keyspaces don't have the same replication settings, effective ownership information is meaningless
cwz@codewithz:~/Desktop/cassandra/apache-cassandra-4.0.12-bin/apache-cassandra-4.0.12$ bin/cqlsh
Connected to Test Cluster at 127.0.0.1:9042
[cqlsh 6.0.0 | Cassandra 4.0.12 | CQL spec 3.4.5 | Native protocol v5]
Use HELP for help.
cqlsh> create keyspace mtn with replication={'class':'SimpleStrategy','replication_factor':1}
   ... ;
cqlsh> use mtn;
cqlsh:mtn> Create table employee (name varchar PRIMARY KEY);
cqlsh:mtn> Insert into employee values ('Zartab');
SyntaxException: line 1:21 no viable alternative at input 'values' (Insert into [employee] values...)
cqlsh:mtn> Insert into employee (namne) values ('Zartab');
InvalidRequest: Error from server: code=2200 [Invalid query] message="Undefined column name namne in table mtn.employee"
cqlsh:mtn> Insert into employee (name) values ('Zartab');
cqlsh:mtn> Insert into employee (name) values ('Daniel');
cqlsh:mtn> Insert into employee (name) values ('Sameul');
cqlsh:mtn> select * from employee;

 name
--------
 Zartab
 Daniel
 Sameul

(3 rows)
cqlsh:mtn> exit
cwz@codewithz:~/Desktop/cassandra/apache-cassandra-4.0.12-bin/apache-cassandra-4.0.12$ bin/nodetool help
 
;
^Ccwz@codewithz:~/Desktop/cassandra/apache-cassandra-4.0.12-bin/apache-cassandra-4.0.12$ bin/nodetool help
usage: nodetool [(-u <username> | --username <username>)]
        [(-h <host> | --host <host>)]
        [(-pwf <passwordFilePath> | --password-file <passwordFilePath>)]
        [(-pw <password> | --password <password>)] [(-p <port> | --port <port>)]
        [(-pp | --print-port)] <command> [<args>]

The most commonly used nodetool commands are:
    assassinate                  Forcefully remove a dead node without re-replicating any data.  Use as a last resort if you cannot removenode
    bootstrap                    Monitor/manage node's bootstrap process
    cleanup                      Triggers the immediate cleanup of keys no longer belonging to a node. By default, clean all keyspaces
    clearsnapshot                Remove the snapshot with the given name from the given keyspaces
    clientstats                  Print information about connected clients
    compact                      Force a (major) compaction on one or more tables or user-defined compaction on given SSTables
    compactionhistory            Print history of compaction
    compactionstats              Print statistics on compactions
    decommission                 Decommission the *node I am connecting to*
    describecluster              Print the name, snitch, partitioner and schema version of a cluster
    describering                 Shows the token ranges info of a given keyspace
    disableauditlog              Disable the audit log
    disableautocompaction        Disable autocompaction for the given keyspace and table
    disablebackup                Disable incremental backup
    disablebinary                Disable native transport (binary protocol)
    disablefullquerylog          Disable the full query log
    disablegossip                Disable gossip (effectively marking the node down)
    disablehandoff               Disable storing hinted handoffs
    disablehintsfordc            Disable hints for a data center
    disableoldprotocolversions   Disable old protocol versions
    drain                        Drain the node (stop accepting writes and flush all tables)
    enableauditlog               Enable the audit log
    enableautocompaction         Enable autocompaction for the given keyspace and table
    enablebackup                 Enable incremental backup
    enablebinary                 Reenable native transport (binary protocol)
    enablefullquerylog           Enable full query logging, defaults for the options are configured in cassandra.yaml
    enablegossip                 Reenable gossip
    enablehandoff                Reenable future hints storing on the current node
    enablehintsfordc             Enable hints for a data center that was previsouly disabled
    enableoldprotocolversions    Enable old protocol versions
    failuredetector              Shows the failure detector information for the cluster
    flush                        Flush one or more tables
    garbagecollect               Remove deleted data from one or more tables
    gcstats                      Print GC Statistics
    getbatchlogreplaythrottle    Print batchlog replay throttle in KB/s. This is reduced proportionally to the number of nodes in the cluster.
    getcompactionthreshold       Print min and max compaction thresholds for a given table
    getcompactionthroughput      Print the MB/s throughput cap for compaction in the system
    getconcurrency               Get maximum concurrency for processing stages
    getconcurrentcompactors      Get the number of concurrent compactors in the system.
    getconcurrentviewbuilders    Get the number of concurrent view builders in the system
    getendpoints                 Print the end points that owns the key
    getfullquerylog              print configuration of fql if enabled, otherwise the configuration reflected in cassandra.yaml
    getinterdcstreamthroughput   Print the Mb/s throughput cap for inter-datacenter streaming in the system
    getlogginglevels             Get the runtime logging levels
    getmaxhintwindow             Print the max hint window in ms
    getseeds                     Get the currently in use seed node IP list excluding the node IP
    getsnapshotthrottle          Print the snapshot_links_per_second throttle for snapshot/clearsnapshot
    getsstables                  Print the sstable filenames that own the key
    getstreamthroughput          Print the Mb/s throughput cap for streaming in the system
    gettimeout                   Print the timeout of the given type in ms
    gettraceprobability          Print the current trace probability value
    gossipinfo                   Shows the gossip information for the cluster
    help                         Display help information
    import                       Import new SSTables to the system
    info                         Print node information (uptime, load, ...)
    invalidatecountercache       Invalidate the counter cache
    invalidatekeycache           Invalidate the key cache
    invalidaterowcache           Invalidate the row cache
    join                         Join the ring
    listsnapshots                Lists all the snapshots along with the size on disk and true size. True size is the total size of all SSTables which are not backed up to disk. Size on disk is total size of the snapshot on disk. Total TrueDiskSpaceUsed does not make any SSTable deduplication.
    move                         Move node on the token ring to a new token
    netstats                     Print network information on provided host (connecting node by default)
    pausehandoff                 Pause hints delivery process
    profileload                  Low footprint profiling of activity for a period of time
    proxyhistograms              Print statistic histograms for network operations
    rangekeysample               Shows the sampled keys held across all keyspaces
    rebuild                      Rebuild data by streaming from other nodes (similarly to bootstrap)
    rebuild_index                A full rebuild of native secondary indexes for a given table
    refresh                      Load newly placed SSTables to the system without restart
    refreshsizeestimates         Refresh system.size_estimates
    reloadlocalschema            Reload local node schema from system tables
    reloadseeds                  Reload the seed node list from the seed node provider
    reloadssl                    Signals Cassandra to reload SSL certificates
    reloadtriggers               Reload trigger classes
    relocatesstables             Relocates sstables to the correct disk
    removenode                   Show status of current node removal, force completion of pending removal or remove provided ID
    repair                       Repair one or more tables
    repair_admin                 list and fail incremental repair sessions
    replaybatchlog               Kick off batchlog replay and wait for finish
    resetfullquerylog            Stop the full query log and clean files in the configured full query log directory from cassandra.yaml as well as JMX
    resetlocalschema             Reset node's local schema and resync
    resumehandoff                Resume hints delivery process
    ring                         Print information about the token ring
    scrub                        Scrub (rebuild sstables for) one or more tables
    setbatchlogreplaythrottle    Set batchlog replay throttle in KB per second, or 0 to disable throttling. This will be reduced proportionally to the number of nodes in the cluster.
    setcachecapacity             Set global key, row, and counter cache capacities (in MB units)
    setcachekeystosave           Set number of keys saved by each cache for faster post-restart warmup. 0 to disable
    setcompactionthreshold       Set min and max compaction thresholds for a given table
    setcompactionthroughput      Set the MB/s throughput cap for compaction in the system, or 0 to disable throttling
    setconcurrency               Set maximum concurrency for processing stage
    setconcurrentcompactors      Set number of concurrent compactors in the system.
    setconcurrentviewbuilders    Set the number of concurrent view builders in the system
    sethintedhandoffthrottlekb   Set hinted handoff throttle in kb per second, per delivery thread.
    setinterdcstreamthroughput   Set the Mb/s throughput cap for inter-datacenter streaming in the system, or 0 to disable throttling
    setlogginglevel              Set the log level threshold for a given component or class. Will reset to the initial configuration if called with no parameters.
    setmaxhintwindow             Set the specified max hint window in ms
    setsnapshotthrottle          Set the snapshot_links_per_second cap for snapshot and clearsnapshot throttling
    setstreamthroughput          Set the Mb/s throughput cap for streaming in the system, or 0 to disable throttling
    settimeout                   Set the specified timeout in ms, or 0 to disable timeout
    settraceprobability          Sets the probability for tracing any given request to value. 0 disables, 1 enables for all requests, 0 is the default
    sjk                          Run commands of 'Swiss Java Knife'. Run 'nodetool sjk --help' for more information.
    snapshot                     Take a snapshot of specified keyspaces or a snapshot of the specified table
    status                       Print cluster information (state, load, IDs, ...)
    statusautocompaction         status of autocompaction of the given keyspace and table
    statusbackup                 Status of incremental backup
    statusbinary                 Status of native transport (binary protocol)
    statusgossip                 Status of gossip
    statushandoff                Status of storing future hints on the current node
    stop                         Stop compaction
    stopdaemon                   Stop cassandra daemon
    tablehistograms              Print statistic histograms for a given table
    tablestats                   Print statistics on tables
    toppartitions                Sample and print the most active partitions
    tpstats                      Print usage statistics of thread pools
    truncatehints                Truncate all hints on the local node, or truncate hints for the endpoint(s) specified.
    upgradesstables              Rewrite sstables (for the requested tables) that are not on the current version (thus upgrading them to said current version)
    verify                       Verify (check data checksum for) one or more tables
    version                      Print cassandra version
    viewbuildstatus              Show progress of a materialized view build

See 'nodetool help <command>' for more information on a specific command.

cwz@codewithz:~/Desktop/cassandra/apache-cassandra-4.0.12-bin/apache-cassandra-4.0.12$ sudo bin/nodetool snapshot mtn
[sudo] password for cwz: 
Requested creating snapshot(s) for [mtn] with snapshot name [1715941251695] and options {skipFlush=false}
Snapshot directory: 1715941251695
cwz@codewithz:~/Desktop/cassandra/apache-cassandra-4.0.12-bin/apache-cassandra-4.0.12$ 




