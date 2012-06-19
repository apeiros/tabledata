# encoding: utf-8

Gem::Specification.new do |s|
  s.name                      = "tables"
  s.version                   = "0.0.1"
  s.authors                   = "Stefan Rusterholz"
  s.description               = <<-DESCRIPTION.gsub(/^    /, '').chomp
    Read tabular data from various formats.
  DESCRIPTION
  s.summary                   = <<-SUMMARY.gsub(/^    /, '').chomp
    Read tabular data from various formats.
  SUMMARY
  s.email                     = "stefan.rusterholz@gmail.com"
  s.files                     =
    Dir['bin/**/*'] +
    Dir['lib/**/*'] +
    Dir['rake/**/*'] +
    Dir['test/**/*'] +
    %w[
      tables.gemspec
      Rakefile
      README.markdown
    ]

  if File.directory?('bin') then
    executables = Dir.chdir('bin') { Dir.glob('**/*').select { |f| File.executable?(f) } }
    s.executables = executables unless executables.empty?
  end

  s.add_dependency 'roo'

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1")
  s.rubygems_version          = "1.3.1"
  s.specification_version     = 3
end
