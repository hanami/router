require 'lotus/routing/resource'
require 'lotus/routing/resources/action'

module Lotus
  module Routing
    class Resources < Resource
      self.actions    = [:index, :new, :create, :show, :edit, :update, :destroy]
      self.action     = Resources::Action
      self.member     = Resources::MemberAction
      self.collection = Resources::CollectionAction
    end
  end
end
