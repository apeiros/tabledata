# encoding: utf-8

require 'base64'
require 'tabledata/processors'

module Tabledata
  class ColumnDefinition
    attr_reader :index
    attr_reader :accessor
    attr_reader :header
    attr_reader :type
    attr_reader :allow_nil
    attr_reader :default
    attr_reader :strip
    attr_reader :pre_validator
    attr_reader :adaptor
    attr_reader :validator
    attr_reader :options

    def initialize(index, accessor, header, type, allow_nil, default, strip, empty_string_is_nil, pre_validator, adaptor, validator, presenter, options)
      @index               = index
      @accessor            = accessor
      @header              = header
      @type                = type
      @allow_nil           = allow_nil
      @default             = default
      @strip               = strip
      @empty_string_is_nil = empty_string_is_nil
      @pre_validator       = pre_validator
      @adaptor             = adaptor
      @validator           = validator
      @presenter           = presenter.is_a?(Proc) ? Hash.new(presenter) : presenter
      @options             = options
      @processor           = Tabledata::Processors.fetch(type).new(options)
    end

    def coerce(value)
      errors  = []
      adapted = nil

      if @pre_validator.nil? || @pre_validator.call(value)
        begin
          value   = value.strip if @strip && value.is_a?(String)
          value   = nil if @empty_string_is_nil && value.is_a?(String) && value.empty?
          adapted = @adaptor ? @adaptor.call(value) : value
          adapted = @default if adapted.nil?
        rescue => exception
          errors << [:exception, exception]
        else
          adapted = @processor.call(adapted, errors) if @processor && !adapted.nil?
          errors << [:invalid_value] if @validator && !adapted.nil? && !@validator.call(adapted)
          errors << [:invalid_nil_value] if adapted.nil? && !@allow_nil
        end
      else
        errors << [:invalid_input]
      end

      [adapted, errors]
    end
  end
end
