require_relative './spec_helper'
require 'graph-backend'
require 'uuid'

API_APP = Graph::Backend::API.new
AUTH_APP = Auth::Backend::App.new(test: true)

module Auth
  class Client
    alias raw_initialize initialize
    def initialize(url, options = {})
      raw_initialize(url, options.merge(adapter: [:rack, AUTH_APP]))
    end
  end
end

require 'auth-backend/test_helpers'
auth_helpers = Auth::Backend::TestHelpers.new(AUTH_APP)
token = auth_helpers.get_token

describe Graph::Client do
  before do
    @client = Graph::Client.new('http://example.com')

    adapter = Service::Client::Adapter::Faraday.new(adapter: [:rack, API_APP])
    @client.client.raw.adapter = adapter

    @entity1 = UUID.new.generate
    @entity2 = UUID.new.generate
  end

  describe "roles" do
    it "can add roles to an entity" do
      @client.list_roles(@entity1, token).wont_include 'developer'
      @client.add_role(@entity1, token, 'developer')
      @client.list_roles(@entity1, token).must_include 'developer'
    end

    it "throws error when trying to add non-existing roles" do
      lambda {
        @client.add_role(@entity1, token, 'mehmeh').must_equal false
      }.must_raise Service::Client::ServiceError
    end

    it "can remove roles from an entity" do
      @client.list_roles(@entity1, token).wont_include 'developer'
      @client.add_role(@entity1, token, 'developer')
      @client.remove_role(@entity1, token, 'developer')
      @client.list_roles(@entity1, token).wont_include 'developer'
    end

    it "does not throw an error when deleting a role which the uuid does not have" do
      @client.remove_role(@entity1, token, 'developer')
    end

    it "can list all entities that have a given role" do
      devs = @client.uuids_by_role(token, 'developer')
      devs.wont_include @entity1
      devs.wont_include @entity2

      @client.add_role(@entity1, token, 'developer')

      devs = @client.uuids_by_role(token, 'developer')
      devs.must_include @entity1
      devs.wont_include @entity2

      @client.add_role(@entity2, token, 'developer')

      devs = @client.uuids_by_role(token, 'developer')
      devs.must_include @entity1
      devs.must_include @entity2
    end
  end

  describe "relations" do
    before do
      @client.add_role(@entity1, token, 'developer')
      @client.add_role(@entity2, token, 'developer')
    end

    describe "adding a relation" do
      it "works outgoing" do
        @client.related?(@entity1, @entity2, token, 'develops').must_equal false
        @client.related?(@entity2, @entity1, token, 'develops').must_equal false

        @client.add_relationship(@entity1, @entity2, token, 'develops')
        @client.related?(@entity1, @entity2, token, 'develops').must_equal true
        @client.related?(@entity2, @entity1, token, 'develops').must_equal false
      end

      it "works incoming" do
        @client.related?(@entity1, @entity2, token, 'develops').must_equal false
        @client.related?(@entity2, @entity1, token, 'develops').must_equal false

        @client.add_relationship(@entity1, @entity2, token, 'develops', direction: 'incoming')

        @client.related?(@entity1, @entity2, token, 'develops').must_equal false
        @client.related?(@entity2, @entity1, token, 'develops').must_equal true
      end

      it "works both ways" do
        @client.related?(@entity1, @entity2, token, 'develops').must_equal false
        @client.related?(@entity2, @entity1, token, 'develops').must_equal false

        @client.add_relationship(@entity1, @entity2, token, 'develops', direction: 'both')

        @client.related?(@entity1, @entity2, token, 'develops').must_equal true
        @client.related?(@entity2, @entity1, token, 'develops').must_equal true
      end
    end

    it "can remove a relationship" do
      @client.related?(@entity1, @entity2, token, 'develops').must_equal false
      @client.related?(@entity2, @entity1, token, 'develops').must_equal false

      @client.add_relationship(@entity1, @entity2, token, 'develops')
      @client.remove_relationship(@entity1, @entity2, token, 'develops')

      @client.related?(@entity1, @entity2, token, 'develops').must_equal false
      @client.related?(@entity2, @entity1, token, 'develops').must_equal false
    end

    it "can list related entities" do
      @entity3 = UUID.new.generate
      @entity4 = UUID.new.generate
      @client.add_role(@entity3, token, 'developer')

      @client.add_relationship(@entity1, @entity2, token, 'develops')
      @client.add_relationship(@entity1, @entity4, token, 'develops')
      @client.add_relationship(@entity2, @entity4, token, 'develops')

      @client.add_relationship(@entity2, @entity3, token, 'develops', direction: 'both')

      related_entities_to_1 = @client.list_related_entities(@entity1, token, 'develops')
      related_entities_to_1.wont_include @entity1
      related_entities_to_1.must_include @entity2
      related_entities_to_1.wont_include @entity3
      related_entities_to_1.must_include @entity4

      related_entities_to_2 = @client.list_related_entities(@entity2, token, 'develops')
      related_entities_to_2.wont_include @entity1
      related_entities_to_2.wont_include @entity2
      related_entities_to_2.must_include @entity3
      related_entities_to_2.must_include @entity4

      related_entities_to_3 = @client.list_related_entities(@entity3, token, 'develops')
      related_entities_to_3.wont_include @entity1
      related_entities_to_3.must_include @entity2
      related_entities_to_3.wont_include @entity3
      related_entities_to_3.wont_include @entity4

      related_entities_to_4 = @client.list_related_entities(@entity4, token, 'develops')
      related_entities_to_4.wont_include @entity1
      related_entities_to_4.wont_include @entity2
      related_entities_to_4.wont_include @entity3
      related_entities_to_4.wont_include @entity4

      related_incoming_entities_to_4 = @client.list_related_entities(@entity4, token, 'develops', direction: 'incoming')
      related_incoming_entities_to_4.must_include @entity1
      related_incoming_entities_to_4.must_include @entity2
      related_incoming_entities_to_4.wont_include @entity3
      related_incoming_entities_to_4.wont_include @entity4

      any_way_related_entities_to_2 = @client.list_related_entities(@entity2, token, 'develops', direction: 'both')
      any_way_related_entities_to_2.must_include @entity1
      any_way_related_entities_to_2.wont_include @entity2
      any_way_related_entities_to_2.must_include @entity3
      any_way_related_entities_to_2.must_include @entity4
    end

    it "can remove an entity with all of it's relations" do
      @entity3 = UUID.new.generate

      @client.add_relationship(@entity1, @entity2, token, 'develops')
      @client.add_relationship(@entity1, @entity3, token, 'develops')
      @client.add_relationship(@entity2, @entity1, token, 'develops')
      @client.add_relationship(@entity2, @entity3, token, 'develops')

      related_entities_to_1 = @client.list_related_entities(@entity1, token, 'develops')
      related_entities_to_1.wont_include @entity1
      related_entities_to_1.must_include @entity2
      related_entities_to_1.must_include @entity3

      related_entities_to_2 = @client.list_related_entities(@entity2, token, 'develops')
      related_entities_to_2.must_include @entity1
      related_entities_to_2.wont_include @entity2
      related_entities_to_2.must_include @entity3

      @client.delete_entity(@entity1, token)

      related_entities_to_1 = @client.list_related_entities(@entity1, token, 'develops')
      related_entities_to_1.empty?.must_equal true

      related_entities_to_2 = @client.list_related_entities(@entity2, token, 'develops')
      related_entities_to_2.wont_include @entity1
      related_entities_to_2.wont_include @entity2
      related_entities_to_2.must_include @entity3
    end

    it "can create relationships with meta data and retrieve the metadata" do
      @entity3 = UUID.new.generate

      @client.add_relationship(@entity1, @entity2, token, 'develops', meta: {os: "Linux"}, direction: 'both')

      @client.relationship_metadata(@entity1, @entity2, token, 'develops').must_equal("os" => "Linux")
      @client.relationship_metadata(@entity2, @entity1, token, 'develops').must_equal("os" => "Linux")

      @client.relationship_metadata(@entity1, @entity3, token, 'develops').must_be_nil
    end
  end
end
