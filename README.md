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
