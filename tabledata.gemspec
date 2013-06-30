# encoding: utf-8

Gem::Specification.new do |s|
  s.name                      = "tabledata"
  s.version                   = "0.0.3"
  s.authors                   = "Stefan Rusterholz"
  s.email                     = "stefan.rusterholz@gmail.com"

  s.description               = <<-DESCRIPTION.gsub(/^    /, '').chomp
    Read tabular data from various formats.
  DESCRIPTION
  s.summary                   = <<-SUMMARY.gsub(/^    /, '').chomp
    Read tabular data from various formats.
  SUMMARY

  s.files                     =
    Dir['bin/**/*'] +
    Dir['lib/**/*'] +
    Dir['rake/**/*'] +
    Dir['test/**/*'] +
    Dir['*.gemspec'] +
    %w[
      LICENSE.txt
      Rakefile
      README.markdown
    ]

  if File.directory?('bin') then
    s.executables = Dir.chdir('bin') { Dir.glob('**/*').select { |f| File.executable?(f) } }
  end

  s.add_dependency 'spreadsheet'
  s.add_dependency 'prawn'
  s.add_dependency 'roo'
  s.add_dependency 'iconv'

  s.ruby_version              = "1.9.2"
  s.rubygems_version          = "1.3.1"
  s.specification_version     = 3
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1")
end
