assert('OptionParser::Option#initialize') do
  option = OptionParser::Option.new(:required, '--long-option', '=value')
  assert_equal :required, option.type, 'type should be :required'
  assert_equal '--long-option', option.name, "name should be '--long-option'"
  assert_equal '=value', option.arg, "arg should be '=value'"
  assert_equal 'value', option.value, "value should be 'value'"
end

assert('OptionParser::Option#style') do
  long_option = OptionParser::Option.new(:required, '--long-option', nil)
  short_option = OptionParser::Option.new(:required, '-a', nil)
  positional = OptionParser::Option.new(:positional, nil, 'value')

  assert_equal :long, long_option.style, 'long option should have :long style'
  assert_equal :short, short_option.style, 'short option should have :short style'
  assert_nil positional.style, 'positional should have nil style'
end

assert('OptionParser::Option.parse') do
  assert('with positional argument') do
    option = OptionParser::Option.parse('value')
    assert_equal :positional, option.type, 'type should be :positional'
    assert_nil option.name, 'name should be nil'
    assert_equal 'value', option.arg, "arg should be 'value'"
  end

  assert('with long option without argument') do
    option = OptionParser::Option.parse('--long-option')
    assert_equal :none, option.type, 'type should be :none'
    assert_equal '--long-option', option.name, "name should be '--long-option'"
    assert_nil option.arg, 'arg should be nil'
  end

  assert('with long option with required argument') do
    option = OptionParser::Option.parse('--long-option=value')
    assert_equal :required, option.type, 'type should be :required'
    assert_equal '--long-option', option.name, "name should be '--long-option'"
    assert_equal '=value', option.arg, "arg should be '=value'"
  end

  assert('with long option with optional argument') do
    option = OptionParser::Option.parse('--long-option=[value]')
    assert_equal :optional, option.type, 'type should be :optional'
    assert_equal '--long-option', option.name, "name should be '--long-option'"
    assert_equal '=[value]', option.arg, "arg should be '=[value]'"
  end

  assert('with short option without argument') do
    option = OptionParser::Option.parse('-a')
    assert_equal :none, option.type, 'type should be :none'
    assert_equal '-a', option.name, "name should be '-a'"
    assert_nil option.arg, 'arg should be nil'
  end

  assert('with short option with argument') do
    option = OptionParser::Option.parse('-a=value')
    assert_equal :required, option.type, 'type should be :required'
    assert_equal '-a', option.name, "name should be '-a'"
    assert_equal '=value', option.arg, "arg should be '=value'"
  end
end

assert('OptionParser::Option.split') do
  assert('with long option without argument') do
    name, arg = OptionParser::Option.split('--long-option')
    assert_equal '--long-option', name, "name should be '--long-option'"
    assert_nil arg, 'arg should be nil'
  end

  assert('with long option with argument') do
    name, arg = OptionParser::Option.split('--long-option=value')
    assert_equal '--long-option', name, "name should be '--long-option'"
    assert_equal '=value', arg, "arg should be '=value'"
  end

  assert('with long option with [no-] prefix') do
    name, arg = OptionParser::Option.split('--[no-]long-option')
    assert_equal '--[no-]long-option', name, "name should be '--[no-]long-option'"
    assert_nil arg, 'arg should be nil'
  end

  assert('with short option without argument') do
    name, arg = OptionParser::Option.split('-a')
    assert_equal '-a', name, "name should be '-a'"
    assert_nil arg, 'arg should be nil'
  end

  assert('with short option with argument') do
    name, arg = OptionParser::Option.split('-a=value')
    assert_equal '-a', name, "name should be '-a'"
    assert_equal '=value', arg, "arg should be '=value'"
  end

  assert('with invalid option') do
    assert_raise(ArgumentError, 'invalid option should raise ArgumentError') do
      OptionParser::Option.split('invalid')
    end
  end
end

assert('OptionParser::Option.guess') do
  assert('with no argument') do
    assert_equal :none, OptionParser::Option.guess(nil), 'nil should return :none'
  end

  assert('with required argument') do
    assert_equal :required, OptionParser::Option.guess('=value'), '=value should return :required'
    assert_equal :required, OptionParser::Option.guess(' value'), ' value should return :required'
  end

  assert('with optional argument') do
    assert_equal :optional, OptionParser::Option.guess('=[value]'), '=[value] should return :optional'
  end

  assert('with placed argument') do
    assert_equal :placed, OptionParser::Option.guess(' [value]'), ' [value] should return :placed'
  end
end
