Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_cielo'
  s.version     = '1.0'
  s.summary     = ''
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Pedro Menezes'
  s.email             = 'eu@pedromenezes.com'
  s.homepage          = 'http://github.com/pedromenezes/spree_cielo'

  s.files        = Dir['CHANGELOG', 'README.markdown', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.30.0')
  s.add_dependency('activemerchant', '>= 1.5.2')
  s.add_dependency('cielo', '>= 0.1.1.beta2')
end