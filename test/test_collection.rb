# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'
require 'metior/collections/collection'

class Dummy
    def id
      __id__
    end
end

class TestCollections < Test::Unit::TestCase

  context 'A collection of objects' do

    setup do
      @collection = Collection.new
      @object1 = Dummy.new
      @object2 = Dummy.new
      @object3 = Dummy.new
      @collection << @object1
      @collection << @object2
      @collection << @object3
    end

    should 'have a simple constructor' do
      collection = Collection.new [@object1, @object2, @object3]
      assert_equal [@object1.id, @object2.id, @object3.id], collection.keys
      assert_equal @object1, collection[@object1.id]
      assert_equal @object2, collection[@object2.id]
      assert_equal @object3, collection[@object3.id]
    end

    should 'be a subclass of Hash' do
      assert_kind_of Hash, @collection
      assert_kind_of OrderedHash, @collection if RUBY_VERSION.match(/^1\.8/)
    end

    should 'have a working << operator' do
      object = Dummy.new
      @collection << object
      assert_equal object, @collection[object.id]
    end

    should 'have a working #each method' do
      objects = []
      result = @collection.each { |obj| objects << obj }
      assert_equal @collection, result
      assert_equal [@object1, @object2, @object3], objects
    end

    should 'have a working #last method' do
      assert_equal @object3, @collection.last
    end

  end

end