# encoding: utf-8

begin
  require 'rubygems/version' # newer rubygems use this
rescue LoadError
  require 'gem/version' # older rubygems use this
end

module Tabledata

  # The version of the tabledata gem.
  Version = Gem::Version.new("0.0.3")
end
