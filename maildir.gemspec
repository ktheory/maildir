# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'maildir/version'

Gem::Specification.new do |s|
  s.name = 'maildir'
  s.version = Maildir::VERSION

  s.authors = ["Aaron Suggs", "Todd A. Jacobs"]
  s.description = "A ruby library for reading and writing arbitrary messages in DJB's maildir format"
  s.email = ["aaron@ktheory.com", "spamivore+maildir.gem@codegnome.org"]
  s.required_rubygems_version = ">= 1.3.5"

  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.rdoc Rakefile)
  s.homepage = 'http://github.com/ktheory/maildir'
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{Read & write messages in the maildir format}
  s.test_files = Dir.glob("test/**/*")

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'mail'
  s.add_development_dependency 'json'
  s.add_development_dependency 'fakefs', ">= 0.3.2"
end

