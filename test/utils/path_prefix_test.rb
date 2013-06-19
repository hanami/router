require 'test_helper'
require 'lotus/utils/path_prefix'

describe Lotus::Utils::PathPrefix do
  it 'exposes itself as a string' do
    prefix = Lotus::Utils::PathPrefix.new
    prefix.must_equal ''
  end

  it 'adds root prefix only when needed' do
    prefix = Lotus::Utils::PathPrefix.new('/fruits')
    prefix.must_equal '/fruits'
  end

  describe '#join' do
    it 'joins a string' do
      prefix = Lotus::Utils::PathPrefix.new('fruits')
      prefix.join('peaches').must_equal '/fruits/peaches'
    end

    it 'joins a prefixed string' do
      prefix = Lotus::Utils::PathPrefix.new('fruits')
      prefix.join('/cherries').must_equal '/fruits/cherries'
    end

    it 'joins a string when the root is blank' do
      prefix = Lotus::Utils::PathPrefix.new
      prefix.join('tea').must_equal '/tea'
    end

    it 'joins a prefixed string when the root is blank' do
      prefix = Lotus::Utils::PathPrefix.new
      prefix.join('/tea').must_equal '/tea'
    end
  end

  describe '#relative_join' do
    it 'joins a string without prefixing with separator' do
      prefix = Lotus::Utils::PathPrefix.new('fruits')
      prefix.relative_join('peaches').must_equal 'fruits/peaches'
    end

    it 'joins a prefixed string without prefixing with separator' do
      prefix = Lotus::Utils::PathPrefix.new('fruits')
      prefix.relative_join('/cherries').must_equal 'fruits/cherries'
    end

    it 'joins a string when the root is blank without prefixing with separator' do
      prefix = Lotus::Utils::PathPrefix.new
      prefix.relative_join('tea').must_equal 'tea'
    end

    it 'joins a prefixed string when the root is blank and removes the prefix' do
      prefix = Lotus::Utils::PathPrefix.new
      prefix.relative_join('/tea').must_equal 'tea'
    end

    it 'joins a string with custom separator' do
      prefix = Lotus::Utils::PathPrefix.new('fruits')
      prefix.relative_join('cherries', '_').must_equal 'fruits_cherries'
    end

    it 'joins a prefixed string without prefixing with custom separator' do
      prefix = Lotus::Utils::PathPrefix.new('fruits')
      prefix.relative_join('_cherries', '_').must_equal 'fruits_cherries'
    end
  end
end
