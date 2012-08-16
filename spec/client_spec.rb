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

  it "can add roles to an entity" do
    @client.list_roles(@entity1).wont_include 'developer'
    @client.add_role(@entity1, 'developer').must_equal true
    @client.list_roles(@entity1).must_include 'developer'
  end

  it "returns false when trying to add non-existing roles" do
    @client.add_role(@entity, 'mehmeh').must_equal false
  end

  it "can remove roles from an antity" do
    @client.list_roles(@entity1).wont_include 'developer'
    @client.add_role(@entity1, 'developer').must_equal true
    @client.remove_role(@entity1, 'developer').must_equal true
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
