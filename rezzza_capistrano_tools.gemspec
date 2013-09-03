Gem::Specification.new do |spec|

  spec.name         = 'rezzza_capistrano_tools'
  spec.version      = '0.1.0.dev'
  spec.platform     = Gem::Platform::RUBY
  spec.description  = <<-DESC
- Vaultage integration
- Diffs between local and remote
  DESC
  spec.summary      = "Some tools for capistrano."
  spec.files        = Dir.glob("lib/**/*") + %w(README.md LICENSE)
  spec.require_path = 'lib'
  spec.has_rdoc     = false

  spec.bindir       = "bin"
  spec.authors      = [ "Les écureuils de Jean-Marc", "RezZza" ]
  spec.email        = [ "py.stephane1@gmail.com"]
  spec.homepage     = "http://verylastroom.com"
  spec.rubyforge_project = "rezzza_capistrano_tools"
end