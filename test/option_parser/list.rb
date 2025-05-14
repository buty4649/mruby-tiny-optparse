assert('OptionParser::List#initialize') do
  list = OptionParser::List.new
  assert_equal({}, list.short, 'short should be empty hash')
  assert_equal({}, list.long, 'long should be empty hash')
  assert_equal([], list.list, 'list should be empty array')
end

assert('OptionParser::List#update') do
  list = OptionParser::List.new
  switch = Object.new

  # Test with short options
  list.update(switch, ['-a', '-b'], nil, nil)
  assert_equal(switch, list.short['-a'], 'short option -a should be registered')
  assert_equal(switch, list.short['-b'], 'short option -b should be registered')

  # Test with long options
  list.update(switch, nil, ['--long1', '--long2'], nil)
  assert_equal(switch, list.long['--long1'], 'long option --long1 should be registered')
  assert_equal(switch, list.long['--long2'], 'long option --long2 should be registered')

  # Test with nolong options
  list.update(switch, nil, nil, ['--[no-]verbose'])
  assert_equal(switch, list.long['--verbose'], 'nolong option --verbose should be registered')
  assert_equal(switch, list.long['--no-verbose'], 'nolong option --no-verbose should be registered')

  # Test removing unused switches
  new_switch = Object.new
  list.update(new_switch, ['-c'], nil, nil)
  assert_equal(new_switch, list.short['-c'], 'new short option -c should be registered')
  assert_equal(switch, list.short['-a'], 'existing short option -a should remain')
end

assert('OptionParser::List#append') do
  list = OptionParser::List.new
  switch = Object.new

  # Test appending a switch
  list.append(switch, ['-a'], ['--long'], ['--[no-]verbose'])
  assert_equal(switch, list.short['-a'], 'short option -a should be registered')
  assert_equal(switch, list.long['--long'], 'long option --long should be registered')
  assert_equal(switch, list.long['--verbose'], 'nolong option --verbose should be registered')
  assert_equal(switch, list.long['--no-verbose'], 'nolong option --no-verbose should be registered')
  assert_equal([switch], list.list, 'switch should be added to list')
end

assert('OptionParser::List#summarize') do
  list = OptionParser::List.new

  # Create a proper Switch mock
  switch = Object.new
  def switch.summarize(_done, indent, _width)
    "#{indent}-a, --long  description"
  end

  # Test with a switch
  list.append(switch, ['-a'], ['--long'], nil)
  assert_equal(['-a, --long  description'], list.summarize, 'summarize should return formatted string')

  # Test with a separator string
  list.append('---', nil, nil, nil)
  assert_equal(['-a, --long  description', '---'], list.summarize, 'summarize should include separator')

  # Test with custom indent and width
  assert_equal(['    -a, --long  description', '---'], list.summarize('    ', 40),
               'summarize should use custom indent and width')
end

assert('OptionParser::List#fetch') do
  list = OptionParser::List.new
  switch = Object.new

  # Test with short option
  list.update(switch, ['-a'], nil, nil)
  assert_equal(switch, list.fetch('-a'), 'fetch should return switch for short option')
  assert_equal(switch, list['-a'], '[] should return switch for short option')

  # Test with long option
  list.update(switch, nil, ['--long'], nil)
  assert_equal(switch, list.fetch('--long'), 'fetch should return switch for long option')
  assert_equal(switch, list['--long'], '[] should return switch for long option')

  # Test with non-existent option
  assert_equal(nil, list.fetch('--nonexistent'), 'fetch should return nil for non-existent option')
  assert_equal(nil, list['--nonexistent'], '[] should return nil for non-existent option')

  # Test with Option object
  option = Object.new
  def option.name
    '--long'
  end

  def option.is_a?(klass)
    klass == OptionParser::Option
  end

  assert_equal(switch, list.fetch(option), 'fetch should return switch for Option object')
  assert_equal(switch, list[option], '[] should return switch for Option object')
end
