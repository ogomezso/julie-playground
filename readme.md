This project use [cp-demo](https://github.com/confluentinc/cp-demo) to create the testing cluster.
Spin up the cluster prior to running any of the examples in this repo


## Running julieOps
You can run it using the CLI or docker
- https://julieops.readthedocs.io/en/3.x/how-to-run-it.html#running-julie-ops-as-a-docker-image

``` bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/config"

docker run -t -i \
      -v ${DIR}:/config \
      --network="julie-playground_default"\
      purbon/kafka-topology-builder:latest \
      /bin/bash -c 'julie-ops-cli.sh --brokers broker:29092 --clientConfig /config/topology-builder.properties  --topology /config/'$1
```
- `-v` is used to mount `${DIR}` (from your local computer) into the container directory `/config`

## julieOps entity definition structure
- uses `json` or `yml` files. Definitions might be composed by multiple files but all of them need to use the same format
- `context:` => Groups projects and there may be many. Usually define a team or a line of business or the origin DC
- ``` yml
        #top of the file
        context: "DC1"
        projects: 
          # [...]
		  ```
- `projects:` => Belongs to a `context`. Groups cluster entity definitions such as: topic, Schemas, permissions (ACLs or RBAC)
- ``` yml
      #top of the file
      context: "DC1"
      projects: 
        - name: "project1"
          - name: "project2"
		  ```

### Entity names
- By default the format for entity names is `context.project.entity-name`
- In between `context:` and `projects`, arbitrary key-value pairs can be defined to compose the name of the desired entity. By default the KV pairs are taken in order.
	- ``` yml
        context: "DC1"
        domain: "foo"
        team: "bar"
        projects: 
          - name: "project1"
			  ```
	- Will define an **entity which name's prefix** is going to be `DC1.foo.bar.project1`

### topics
- managing topics with Julie is done using the key `topics:` which is nested under a project
#### Attributes
- `name:` topic name
- `dataType:` defines the data format the topic uses between *avro, protobuf or json schema*
- `schemas:` schema definition dictionary
	- `value.schema.file:` schema for the subject value
	- `key.schema.file:` schema for the subject key
	- `value.record.type:` the name of the specific record if using `[Topic]RecordNameStrategy` for subjects
	- `key.record.type:` the name of the specific record if using `[Topic]RecordNameStrategy` for subjects
	- `key.format:` defines the data format used. Required if the key and the value use a different format
	- `value.compatibility:` sets the *compatibility mode* for the subject.
		- https://docs.confluent.io/platform/current/schema-registry/avro.html#summary
- `subject.name.strategy:` defines the strategy for naming Schema Registry subjects
	- https://docs.confluent.io/platform/current/schema-registry/serdes-develop/index.html#overview
- `consumers:` gives access to one or many consumers to the specific topic
	- `principal:` consumer principal
- `producers:` gives access to one or many producers to the specific topic
	- `principal:` producer principal
- `config:` controls topic configuration. Each configuration property uses the same name and values as if you configure a topic elsewhere

### connectors**
- Uses the key `connectors:` nested under a project
#### Attributes
- `artifacts:` Set of connector artifacts to manage
  - `path:` path to the connector json configuration. Path is relative to the descriptor
  - `server:` name of the connect node 
  - `name` name of the connector. Needs to match with the name in the connector json config
- `access-control:` set of permissions gave to the specific connector principal you want to use
  - `principal:` name of the connector principal
  - `topics:` target topic for permissions
    - `read:` gives read permissions. Contains a list of topics
    - `write:` gives write permissions. Contains a list of topics
- `principal:` principal connector uses target for permission. If used at this level, `artifacts:` can't be defined
- `connectors:` used when defining principals (the attribute just above). Lists connectors that `principal:` will have access to

### Ksql
-  Uses the key `ksql:` nested under a project
#### Attributes 
- `artifacts:` Set of ksql artifacts to manage (tables, streams..)
  - `tables:` deploys a table query
    - `path:` path to the `sql` file with the query. The path is relative to the descriptor
    - `name:` name of the query
  - `stream:` deploys a stream query
    - `path:` path to the `sql` file with the query. The path is relative to the descriptor
    - `name:` name of the query