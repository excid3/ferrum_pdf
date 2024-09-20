require_relative "lib/ferrum_pdf/version"

Gem::Specification.new do |spec|
  spec.name        = "ferrum_pdf"
  spec.version     = FerrumPdf::VERSION
  spec.authors     = [ "Chris Oliver" ]
  spec.email       = [ "excid3@gmail.com" ]
  spec.homepage    = "https://github.com/excid3/ferrum_pdf"
  spec.summary     = "PDFs for Rails using Ferrum & headless Chrome"
  spec.description = "Export PDFs from HTML in Rails using Ferrum & headless Chrome"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2.1"
  spec.add_dependency "ferrum", "~> 0.15"
end
