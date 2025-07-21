# This file works with both CRuby and mruby
unless Object.const_defined?(:OptionParser)
  require_relative '../mrblib/option_parser'
  require_relative '../mrblib/option_parser/option'
  require_relative '../mrblib/option_parser/switch'
  require_relative '../mrblib/option_parser/list'
  require_relative '../mrblib/option_parser/error'
end

opts = OptionParser.new

opts.banner = 'Usage: example [options]'
opts.separator ''

opts.on('--abc HOGE', 'description of -a') { |v| puts "-a v: #{v}" }
opts.on('--better', 'description of --better') { puts '--better' }
opts.on('--count=[number]', 'description of --count') { |v| puts "--count v: #{v}" }

opts.separator('--------------------------------')

opts.on('--[no-]debug', 'description of --no-debug') { |v| puts "--no-debug #{v}" }

puts opts.parse(%w[--abc HOGE --better --count=100 --no-debug test])

puts
puts opts.help
