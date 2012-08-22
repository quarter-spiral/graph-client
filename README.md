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
client.uuids_by_role(role)
```

#### Add a role

```ruby
client.add_role(uuid, 'developer')
```

#### Remove a role

```ruby
client.remove_role(uuid, 'developer')
```

### Relationships

#### Check for a relationship

```ruby
client.related?(uuid1, uuid2, 'develops')
```

#### Add a relationship

```ruby
options = {direction: 'both'}
client.add_relationship(uuid1, uuid2, 'develops', options)
```

Available options:

* **direction**: Direction of the relationship. Possible values:
  ``outgoing`` (default), ``incoming`` and ``both``

#### Remove a relationship

```ruby
client.remove_relationship(uuid1, uuid2, 'develops')
```

#### List related entities to an entity

```ruby
client.list_related_entities(uuid, 'develops', options) # => [uuid1, uuid2]
```

Available options:

* **direction**: Direction of the relationships. Possible values:
  ``outgoing`` (default), ``incoming`` and ``both``

#### Remove an entity and all of it's relations

```ruby
client.delete_entity(uuid)
```
