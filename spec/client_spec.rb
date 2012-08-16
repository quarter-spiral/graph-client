require_relative './spec_helper'
require 'graph-backend'
require 'uuid'

describe Graph::Client do
  before do
    @client = Graph::Client.new('http://example.com')

    adapter = Service::Client::Adapter::Faraday.new(adapter: [:rack, Graph::Backend::API.new])
    @client.client.raw.adapter = adapter

    @entity1 = UUID.new.generate
    @entity2 = UUID.new.generate
  end

  describe "roles" do
    it "can add roles to an entity" do
      @client.list_roles(@entity1).wont_include 'developer'
      @client.add_role(@entity1, 'developer')
      @client.list_roles(@entity1).must_include 'developer'
    end

    it "throws error when trying to add non-existing roles" do
      lambda {
        @client.add_role(@entity1, 'mehmeh').must_equal false
      }.must_raise Service::Client::ServiceError
    end

    it "can remove roles from an entity" do
      @client.list_roles(@entity1).wont_include 'developer'
      @client.add_role(@entity1, 'developer')
      @client.remove_role(@entity1, 'developer')
      @client.list_roles(@entity1).wont_include 'developer'
    end

    it "does not throw an error when deleting a role which the uuid does not have" do
      @client.remove_role(@entity1, 'developer')
    end

    it "can list all entities that have a given role" do
      devs = @client.uuids_by_role('developer')
      devs.wont_include @entity1
      devs.wont_include @entity2

      @client.add_role(@entity1, 'developer')

      devs = @client.uuids_by_role('developer')
      devs.must_include @entity1
      devs.wont_include @entity2

      @client.add_role(@entity2, 'developer')

      devs = @client.uuids_by_role('developer')
      devs.must_include @entity1
      devs.must_include @entity2
    end
  end

  describe "relations" do
    describe "adding a relation" do
      it "works outgoing" do
        @client.related?(@entity1, @entity2, 'develops').must_equal false
        @client.related?(@entity2, @entity1, 'develops').must_equal false

        @client.add_relationship(@entity1, @entity2, 'develops')
        @client.related?(@entity1, @entity2, 'develops').must_equal true
        @client.related?(@entity2, @entity1, 'develops').must_equal false
      end

      it "works incoming" do
        @client.related?(@entity1, @entity2, 'develops').must_equal false
        @client.related?(@entity2, @entity1, 'develops').must_equal false

        @client.add_relationship(@entity1, @entity2, 'develops', direction: 'incoming')

        @client.related?(@entity1, @entity2, 'develops').must_equal false
        @client.related?(@entity2, @entity1, 'develops').must_equal true
      end

      it "works both ways" do
        @client.related?(@entity1, @entity2, 'develops').must_equal false
        @client.related?(@entity2, @entity1, 'develops').must_equal false

        @client.add_relationship(@entity1, @entity2, 'develops', direction: 'both')

        @client.related?(@entity1, @entity2, 'develops').must_equal true
        @client.related?(@entity2, @entity1, 'develops').must_equal true
      end
    end

    it "can remove a relationship" do
      @client.related?(@entity1, @entity2, 'develops').must_equal false
      @client.related?(@entity2, @entity1, 'develops').must_equal false

      @client.add_relationship(@entity1, @entity2, 'develops')
      @client.remove_relationship(@entity1, @entity2, 'develops')

      @client.related?(@entity1, @entity2, 'develops').must_equal false
      @client.related?(@entity2, @entity1, 'develops').must_equal false
    end

    it "can list related entities" do
      @entity3 = UUID.new.generate
      @entity4 = UUID.new.generate

      @client.add_relationship(@entity1, @entity2, 'develops')
      @client.add_relationship(@entity1, @entity4, 'develops')

      @client.add_relationship(@entity2, @entity3, 'develops', direction: 'both')

      related_entities_to_1 = @client.list_related_entities(@entity1, 'develops')
      related_entities_to_1.wont_include @entity1
      related_entities_to_1.must_include @entity2
      related_entities_to_1.wont_include @entity3
      related_entities_to_1.must_include @entity4

      related_entities_to_2 = @client.list_related_entities(@entity2, 'develops')
      related_entities_to_2.wont_include @entity1
      related_entities_to_2.wont_include @entity2
      related_entities_to_2.must_include @entity3
      related_entities_to_2.wont_include @entity4

      related_entities_to_3 = @client.list_related_entities(@entity3, 'develops')
      related_entities_to_3.wont_include @entity1
      related_entities_to_3.must_include @entity2
      related_entities_to_3.wont_include @entity3
      related_entities_to_3.wont_include @entity4

      related_entities_to_4 = @client.list_related_entities(@entity4, 'develops')
      related_entities_to_4.wont_include @entity1
      related_entities_to_4.wont_include @entity2
      related_entities_to_4.wont_include @entity3
      related_entities_to_4.wont_include @entity4
    end
  end
end
