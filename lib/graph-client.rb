require "graph-client/version"

require "service-client"

module Graph
  class Client
    API_VERSION = 'v1'

    attr_reader :client

    def initialize(url)
      @client = Service::Client.new(url)

      # Roles
      @client.urls.add(:role, :get,    "/#{API_VERSION}/entities/:uuid:/roles")
      @client.urls.add(:role, :post,   "/#{API_VERSION}/entities/:uuid:/roles/:role:")
      @client.urls.add(:role, :delete, "/#{API_VERSION}/entities/:uuid:/roles/:role:")
      @client.urls.add(:everyone_with_role, :get,  "/#{API_VERSION}/roles/:role:")

      # Relationships
      @client.urls.add(:relationship, :get,      "/#{API_VERSION}/entities/:uuid1:/:relation_type:/:uuid2:")
      @client.urls.add(:relationship, :post,     "/#{API_VERSION}/entities/:uuid1:/:relation_type:/:uuid2:")
      @client.urls.add(:relationship, :delete,   "/#{API_VERSION}/entities/:uuid1:/:relation_type:/:uuid2:")
      @client.urls.add(:relationship_list, :get, "/#{API_VERSION}/entities/:uuid:/:relation_type:")
      @client.urls.add(:query, :get, "/#{API_VERSION}/query/:uuids:")

      # Entities
      @client.urls.add(:entities, :delete, "/#{API_VERSION}/entities/:uuid:")
    end

    def list_roles(uuid,token)
      @client.get(@client.urls.role(uuid: uuid), token).data
    end

    def add_role(uuid, token, role)
      @client.post(@client.urls.role(uuid: uuid, role: role), token)
    end

    def query(token, uuids, query)
      @client.get(@client.urls.query(uuids: uuids.join("/")), token, query: query).data
    end

    def remove_role(uuid, token, role)
      @client.delete(@client.urls.role(uuid: uuid, role: role), token)
    end

    def uuids_by_role(token, role)
      @client.get(@client.urls.everyone_with_role(role: role), token).data
    end

    def related?(uuid1, uuid2, token, relation_type)
      @client.get(@client.urls.relationship(uuid1: uuid1, uuid2: uuid2, relation_type: relation_type), token)
      true
    rescue Service::Client::ServiceError => e
      return false if e.error == "Not found"
      raise e
    end

    def relationship_metadata(uuid1, uuid2, token, relation_type)
      @client.get(@client.urls.relationship(uuid1: uuid1, uuid2: uuid2, relation_type: relation_type), token).data['meta']
    rescue Service::Client::ServiceError => e
      return nil if e.error == "Not found"
      raise e
    end

    def add_relationship(uuid1, uuid2, token, relation_type, options = {})
      direction = options.delete(:direction)
      meta = options.delete(:meta) || {}
      @client.post(@client.urls.relationship(uuid1: uuid1, uuid2: uuid2, relation_type: relation_type), token, direction: direction, meta: meta)
    end

    def remove_relationship(uuid1, uuid2, token, relation_type)
      @client.delete(@client.urls.relationship(uuid1: uuid1, uuid2: uuid2, relation_type: relation_type), token)
    end

    def list_related_entities(uuid, token, relation_type, options = {})
      direction = options.delete(:direction)
      @client.get(@client.urls.relationship_list(uuid: uuid, relation_type: relation_type), token, direction: direction).data.map {|c| c['target']}
    end

    def delete_entity(uuid, token)
      @client.delete(@client.urls.entities(uuid), token)
    end
  end
end
