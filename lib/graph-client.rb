require "graph-client/version"

require "service-client"

module Graph
  class Client
    API_VERSION = 'v1'

    attr_reader :client

    def initialize(url)
      @client = Service::Client.new(url)
      @client.urls.add(:role, :get,"/#{API_VERSION}/entities/:uuid:/roles")
      @client.urls.add(:role, :post, "/#{API_VERSION}/entities/:uuid:/roles/:role:")
      @client.urls.add(:role, :delete,  "/#{API_VERSION}/entities/:uuid:/roles/:role:")
      @client.urls.add(:everyone_with_role, :get,  "/#{API_VERSION}/roles/:role:")
    end

    def list_roles(uuid)
      @client.get(@client.urls.role(uuid: uuid)).data
    end

    def add_role(uuid, role)
      @client.post(@client.urls.role(uuid: uuid, role: role))
      true
    rescue Service::Client::ResponseError => e
      return false if e.response.status == 404
      raise e
    end

    def remove_role(uuid, role)
      @client.delete(@client.urls.role(uuid: uuid, role: role))
      true
    end

    def uuids_by_role(role)
      @client.get(@client.urls.everyone_with_role(role: role)).data
    end
  end
end
