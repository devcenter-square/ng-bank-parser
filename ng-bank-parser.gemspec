# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ng-bank-parser/version'

Gem::Specification.new do |spec|
  spec.name          = "ng-bank-parser"
  spec.version       = NgBankParser::VERSION
  spec.authors       = ["Opemipo Aikomo","Timilehin Ajiboye","Lolu Bodunwa","Oluro Olaoluwa"]
  spec.email         = ["opemipoaikomo@gmail.com"]

  spec.summary       = %q{This is a simple gem to parse Nigerian bank statements of all formats created by Devcenter Square}
  spec.description   = %q{This is a simple gem to parse Nigerian bank statements of all formats. This is a community project by Devcenter Square (devcenter-square.github.io). If your bank and/or file format is not supported, consider reading the contribute wiki and submitting a pull request.}
  spec.homepage      = "http://devcenter-square.github.io/ng-bank-parser/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_dependency "nokogiri"
  spec.add_dependency "roo"
  spec.add_dependency "pdf-reader"
  spec.add_dependency "activesupport"
  spec.add_dependency 'rest-client'
end
