# Graph::Client

Client to the datastore-backend.

## Installation

```
gem install graph-client
```

## Usage

### Create a client
```ruby
# connect to local
client = Graph::Client.new('http://graph-backend.dev')
```

### Roles

#### List all UUIDs with a role

```ruby
client.uuids_by_role(token, role)
```

#### Add a role

```ruby
client.add_role(uuid, token, 'developer')
```

#### Remove a role

```ruby
client.remove_role(uuid, token, 'developer')
```

### Relationships

#### Check for a relationship

```ruby
client.related?(uuid1, uuid2, token, 'develops')
```

#### Get a relationship's meta data

Returns a Hash with the meta data or nil if the relationship does not exist.

```ruby
client.relationship_metadata(uuid1, uuid2, token, 'develops')
```

#### Change a relationship's meta data

Returns normal information on the relationship. The same data you get when adding a relationship.

```ruby
client.change_relationship(uuid1, uuid2, token, 'develops', {location: "Berlin"})
```

#### Add a relationship

```ruby
options = {direction: 'both'}
client.add_relationship(uuid1, uuid2, token, 'develops', options)
```

Available options:

* **direction**: Direction of the relationship. Possible values:
  ``outgoing`` (default), ``incoming`` and ``both``
* **meta**: Meta information to this relationship. Must be a shallow, one level deep hash (works: ``{location: 'Rome'}`` does not work: ``{location: {city: 'Rome'}}``).

#### Issue a cypher query

```ruby
client.query(token, [player_uuid], "MATCH node0-[:friends]->()-[:friends]->fof RETURN fof.uuid")
```

#### Remove a relationship

```ruby
client.remove_relationship(uuid1, uuid2, token, 'develops')
```

#### List related entities to an entity

```ruby
client.list_related_entities(uuid, token, 'develops', options) # => [uuid1, uuid2]
```

Available options:

* **direction**: Direction of the relationships. Possible values:
  ``outgoing`` (default), ``incoming`` and ``both``

#### Remove an entity and all of it's relations

```ruby
client.delete_entity(uuid, token)
```
