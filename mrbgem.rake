MRuby::Gem::Specification.new('mruby-tiny-optparse') do |spec|
  spec.license = 'MIT'
  spec.author  = 'buty4649'
  spec.summary = 'A lightweight and linky optparse-style library for mruby'
  spec.version = '0.3.1'

  spec.add_dependency 'mruby-array-ext', core: 'mruby-array-ext'
  spec.add_dependency 'mruby-sprintf', core: 'mruby-sprintf'
  spec.add_dependency 'mruby-string-ext', core: 'mruby-string-ext'

  spec.add_test_dependency 'mruby-test-stub', github: 'buty4649/mruby-test-stub', branch: 'main'
end
