# encoding: utf-8

module Tabledata
  module Coercion
    @coerce = {}

    def self.[](key)
      @coerce[key]
    end

    def self.coercing(key, &block)
      @coerce[key] = block
    end

    coercing String do |value, format|
      value.to_s
    end

    coercing Integer do |value, format|
      Integer(value, format.fetch(:base, 10))
    end

    coercing Date do |value, format|
    end
  end
end
