assert('OptionParser error classes') do
  assert('ParseError is defined') do
    assert_true OptionParser.const_defined?(:ParseError), 'ParseError should be defined'
    assert_equal StandardError, OptionParser::ParseError.superclass, 'ParseError should inherit from StandardError'
  end

  assert('InvalidOption is defined') do
    assert_true OptionParser.const_defined?(:InvalidOption), 'InvalidOption should be defined'
    assert_equal OptionParser::ParseError, OptionParser::InvalidOption.superclass, 'InvalidOption should inherit from ParseError'
  end

  assert('MissingArgument is defined') do
    assert_true OptionParser.const_defined?(:MissingArgument), 'MissingArgument should be defined'
    assert_equal OptionParser::ParseError, OptionParser::MissingArgument.superclass, 'MissingArgument should inherit from ParseError'
  end

  assert('NeedlessArgument is defined') do
    assert_true OptionParser.const_defined?(:NeedlessArgument), 'NeedlessArgument should be defined'
    assert_equal OptionParser::ParseError, OptionParser::NeedlessArgument.superclass, 'NeedlessArgument should inherit from ParseError'
  end
end

assert('OptionParser::InvalidOption') do
  assert('raised for unknown option') do
    parser = OptionParser.new

    assert_raise(OptionParser::InvalidOption, 'should raise InvalidOption for unknown short option') do
      parser.parse(['-x'])
    end

    assert_raise(OptionParser::InvalidOption, 'should raise InvalidOption for unknown long option') do
      parser.parse(['--unknown'])
    end
  end

  assert('exception message contains option name') do
    parser = OptionParser.new

    begin
      parser.parse(['-x'])
      assert_false true, 'should have raised InvalidOption'
    rescue OptionParser::InvalidOption => e
      assert_true e.message.include?('-x'), 'exception message should contain option name'
    end

    begin
      parser.parse(['--unknown'])
      assert_false true, 'should have raised InvalidOption'
    rescue OptionParser::InvalidOption => e
      assert_true e.message.include?('--unknown'), 'exception message should contain option name'
    end
  end
end

assert('OptionParser::MissingArgument') do
  assert('raised for required argument missing') do
    parser = OptionParser.new
    parser.on('-f FILE', 'input file')
    parser.on('--file FILE', 'input file')

    assert_raise(OptionParser::MissingArgument, 'should raise MissingArgument for short option without argument') do
      parser.parse(['-f'])
    end

    assert_raise(OptionParser::MissingArgument, 'should raise MissingArgument for long option without argument') do
      parser.parse(['--file'])
    end
  end

  assert('exception message contains option name') do
    parser = OptionParser.new
    parser.on('-f FILE', 'input file')

    begin
      parser.parse(['-f'])
      assert_false true, 'should have raised MissingArgument'
    rescue OptionParser::MissingArgument => e
      assert_true e.message.include?('-f'), 'exception message should contain option name'
    end
  end
end

assert('OptionParser::NeedlessArgument') do
  assert('raised for flag option with argument') do
    parser = OptionParser.new
    parser.on('-v', 'verbose mode')

    assert_raise(OptionParser::NeedlessArgument, 'should raise NeedlessArgument for flag option with = argument') do
      parser.parse(['-v=value'])
    end
  end

  assert('raised for long flag option with argument') do
    parser = OptionParser.new
    parser.on('--verbose', 'verbose mode')

    assert_raise(OptionParser::NeedlessArgument, 'should raise NeedlessArgument for long flag option with = argument') do
      parser.parse(['--verbose=value'])
    end
  end

  assert('exception message contains option name') do
    parser = OptionParser.new
    parser.on('-v', 'verbose mode')

    begin
      parser.parse(['-v=value'])
      assert_false true, 'should have raised NeedlessArgument'
    rescue OptionParser::NeedlessArgument => e
      assert_true e.message.include?('-v'), 'exception message should contain option name'
    end
  end
end
