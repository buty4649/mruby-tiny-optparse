assert('OptionParser#parse') do
  assert('concatenated short options') do
    parser = OptionParser.new
    a_result = nil
    b_result = nil
    c_result = nil
    parser.on('-a', 'option a') { |v| a_result = v }
    parser.on('-b', 'option b') { |v| b_result = v }
    parser.on('-c', 'option c') { |v| c_result = v }

    args = parser.parse(['-abc'])
    assert_equal true, a_result, 'option -a should be set to true'
    assert_equal true, b_result, 'option -b should be set to true'
    assert_equal true, c_result, 'option -c should be set to true'
    assert_equal [], args, 'all options should be consumed'
  end

  assert('placed short option with argument') do
    parser = OptionParser.new
    result = nil
    parser.on('-a FOO', 'option a') { |v| result = v }

    args = parser.parse(['-a', 'foo'])
    assert_equal 'foo', result, 'option -a should be set to foo'
    assert_true args.empty?, 'argument should be consumed'
  end

  assert('missing required argument for short option') do
    parser = OptionParser.new
    parser.on('-aFOO', 'option a')

    assert_raise(OptionParser::MissingArgument, 'should raise MissingArgument for short option') do
      parser.parse(['-a'])
    end
  end

  assert('missing required argument for long option') do
    parser = OptionParser.new
    parser.on('--arg FOO', 'option arg')

    assert_raise(OptionParser::MissingArgument, 'should raise MissingArgument for long option') do
      parser.parse(['--arg'])
    end
  end

  assert('positional option') do
    parser = OptionParser.new
    result = nil
    parser.on('-a', 'option a') { |v| result = v }

    args = parser.parse(['-a', 'foo'])
    assert_equal true, result, 'option -a should be set to true'
    assert_equal ['foo'], args, 'argument should be returned as positional argument'
  end

  assert('arguments after -- separator') do
    parser = OptionParser.new
    a_result = nil
    b_result = nil
    parser.on('-a', 'option a') { |v| a_result = v }
    parser.on('-b', 'option b') { |v| b_result = v }

    args = parser.parse(['-a', '--', '-b'])
    assert_equal true, a_result, 'option -a should be set to true'
    assert_equal nil, b_result, 'option -b should not be set'
    assert_equal ['-b'], args, '-b should be treated as positional argument'
  end

  assert('combination of short and long options') do
    parser = OptionParser.new
    a_result = nil
    verbose_result = nil
    parser.on('-a', 'option a') { |v| a_result = v }
    parser.on('--verbose', 'verbose mode') { |v| verbose_result = v }

    args = parser.parse(['-a', '--verbose'])
    assert_equal true, a_result, 'option -a should be set to true'
    assert_equal true, verbose_result, 'option --verbose should be set to true'
    assert_equal [], args, 'all options should be consumed'
  end

  assert('combination of options with and without arguments') do
    parser = OptionParser.new
    a_result = nil
    file_result = nil
    parser.on('-a', 'option a') { |v| a_result = v }
    parser.on('-f FILE', 'input file') { |v| file_result = v }

    args = parser.parse(['-a', '-f', 'test.txt'])
    assert_equal true, a_result, 'option -a should be set to true'
    assert_equal 'test.txt', file_result, 'option -f should be set to test.txt'
    assert_equal [], args, 'all options should be consumed'
  end

  assert('multiple options with arguments') do
    parser = OptionParser.new
    input_result = nil
    output_result = nil
    parser.on('-i INPUT', 'input file') { |v| input_result = v }
    parser.on('-o OUTPUT', 'output file') { |v| output_result = v }

    args = parser.parse(['-i', 'input.txt', '-o', 'output.txt'])
    assert_equal 'input.txt', input_result, 'option -i should be set to input.txt'
    assert_equal 'output.txt', output_result, 'option -o should be set to output.txt'
    assert_equal [], args, 'all options should be consumed'
  end

  assert('later option definition takes precedence') do
    parser = OptionParser.new
    file_result = nil
    flag_result = nil
    parser.on('-f', '--file FILE', 'input file') { |v| file_result = v }
    parser.on('-f', 'flag option') { |v| flag_result = v }

    args = parser.parse(['-f'])
    assert_equal nil, file_result, 'first -f definition should not be called'
    assert_equal true, flag_result, 'second -f definition should be called'
    assert_equal [], args, 'all options should be consumed'
  end
end
