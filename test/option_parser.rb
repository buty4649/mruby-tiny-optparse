assert('OptionParser#initialize') do
  parser = OptionParser.new
  assert_equal '', parser.banner, 'banner should be empty string by default'
  assert_equal '  ', parser.summary_indent, 'summary_indent should be two spaces by default'
  assert_equal 32, parser.summary_width, 'summary_width should be 32 by default'
end

assert('OptionParser#summary_width=') do
  parser = OptionParser.new
  parser.summary_width = 40
  assert_equal 40, parser.summary_width, 'summary_width should be set to 40'

  assert_raise(ArgumentError, 'negative width should raise ArgumentError') { parser.summary_width = -1 }
  assert_raise(ArgumentError, 'zero width should raise ArgumentError') { parser.summary_width = 0 }
  assert_raise(ArgumentError, 'non-integer width should raise ArgumentError') { parser.summary_width = 'invalid' }
end

assert('OptionParser#on') do
  parser = OptionParser.new

  assert('with short option') do
    result = nil
    parser.on('-v', 'verbose mode') { |v| result = v }
    args = parser.parse(['-v'])
    assert_equal true, result, 'short option should set result to true'
    assert_equal [], args, 'short option should consume the argument'
  end

  assert('with long option') do
    result = nil
    parser.on('--verbose', 'verbose mode') { |v| result = v }
    args = parser.parse(['--verbose'])
    assert_equal true, result, 'long option should set result to true'
    assert_equal [], args, 'long option should consume the argument'
  end

  assert('with required argument') do
    result = nil
    parser.on('-f', '--file FILE', 'specify file') { |f| result = f }
    args = parser.parse(['-f', 'test.txt'])
    assert_equal 'test.txt', result, 'required argument should be passed to block'
    assert_equal [], args, 'option and argument should be consumed'
  end

  assert('with optional argument') do
    result = nil
    parser.on('-f', '--file [FILE]', 'specify file') { |f| result = f }
    args = parser.parse(['-f'])
    assert_nil result, 'optional argument should set result to nil when not provided'
    assert_equal [], args, 'option should be consumed'
  end

  assert('with --[no-]option pattern') do
    result = nil
    parser.on('--[no-]verbose', 'verbose mode') { |v| result = v }

    args = parser.parse(['--verbose'])
    assert_equal true, result, '--[no-]option pattern should set result to true with positive form'
    assert_equal [], args, 'option should be consumed'

    result = nil
    args = parser.parse(['--no-verbose'])
    assert_equal false, result, '--[no-]option pattern should set result to false with negative form'
    assert_equal [], args, 'option should be consumed'
  end
end

assert('OptionParser#help') do
  parser = OptionParser.new
  parser.banner = 'Usage: test [options]'
  parser.on('-v', '--verbose', 'verbose mode')
  parser.on('-f', '--file FILE', 'specify file')
  parser.on('--[no-]debug', 'debug mode')
  parser.separator('')
  parser.separator('Common options:')

  expected = <<~EXPECTED.chomp
    Usage: test [options]
      -v, --verbose                     verbose mode
      -f, --file FILE                   specify file
          --[no-]debug                  debug mode

    Common options:
  EXPECTED

  assert_equal expected, parser.help, 'help should show options with default indentation and width'

  assert('with custom summary_indent') do
    parser = OptionParser.new
    parser.banner = 'Usage: test [options]'
    parser.on('-v', '--verbose', 'verbose mode')
    parser.on('-f', '--file FILE', 'specify file')
    parser.separator('')
    parser.separator('Common options:')
    parser.summary_indent = '    '

    expected = <<~EXPECTED.chomp
      Usage: test [options]
          -v, --verbose                     verbose mode
          -f, --file FILE                   specify file

      Common options:
    EXPECTED

    assert_equal expected, parser.help, 'help should show options with custom indentation (4 spaces)'
  end

  assert('with custom summary_width') do
    parser = OptionParser.new
    parser.banner = 'Usage: test [options]'
    parser.on('-v', '--verbose', 'verbose mode')
    parser.on('-f', '--file FILE', 'specify file')
    parser.separator('')
    parser.separator('Common options:')
    parser.summary_width = 20

    expected = <<~EXPECTED.chomp
      Usage: test [options]
        -v, --verbose         verbose mode
        -f, --file FILE       specify file

      Common options:
    EXPECTED

    assert_equal expected, parser.help, 'help should show options with custom width (20)'
  end
end
