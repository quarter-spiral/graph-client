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

      # Entities
      @client.urls.add(:entities, :delete, "/#{API_VERSION}/entities/:uuid:")
    end

    def list_roles(uuid)
      @client.get(@client.urls.role(uuid: uuid)).data
    end

    def add_role(uuid, role)
      @client.post(@client.urls.role(uuid: uuid, role: role))
    end

    def remove_role(uuid, role)
      @client.delete(@client.urls.role(uuid: uuid, role: role))
    end

    def uuids_by_role(role)
      @client.get(@client.urls.everyone_with_role(role: role)).data
    end

    def related?(uuid1, uuid2, relation_type)
      @client.get(@client.urls.relationship(uuid1: uuid1, uuid2: uuid2, relation_type: relation_type))
      true
    rescue Service::Client::ServiceError => e
      return false if e.error == "Not found"
      raise e
    end

    def add_relationship(uuid1, uuid2, relation_type, options = {})
      direction = options.delete(:direction)
      @client.post(@client.urls.relationship(uuid1: uuid1, uuid2: uuid2, relation_type: relation_type), direction: direction)
    end

    def remove_relationship(uuid1, uuid2, relation_type)
      @client.delete(@client.urls.relationship(uuid1: uuid1, uuid2: uuid2, relation_type: relation_type))
    end

    def list_related_entities(uuid, relation_type, options = {})
      direction = options.delete(:direction)
      @client.get(@client.urls.relationship_list(uuid: uuid, relation_type: relation_type), direction: direction).data
    end

    def delete_entity(uuid)
      @client.delete(@client.urls.entities(uuid))
    end
  end
end
