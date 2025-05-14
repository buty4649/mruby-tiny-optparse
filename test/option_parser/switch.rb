assert('OptionParser::Switch#initialize') do
  switch = OptionParser::Switch.new(
    ['-a'],                    # short options
    ['--all'],                 # long options
    ['--no-all'],             # no-long options
    'ARG',                    # argument
    'description of option', # description
    :string, # type
    ->(arg) { arg } # block
  )

  assert_equal ['-a'], switch.short, 'short options should be set correctly'
  assert_equal ['--all'], switch.long, 'long options should be set correctly'
  assert_equal ['--no-all'], switch.nolong, 'no-long options should be set correctly'
  assert_equal 'ARG', switch.arg, 'argument should be set correctly'
  assert_equal 'description of option', switch.description, 'description should be set correctly'
  assert_equal :string, switch.type, 'type should be set correctly'
  assert_true switch.block.is_a?(Proc), 'block should be a Proc'
end

assert('OptionParser::Switch#summarize') do
  switch = OptionParser::Switch.new(
    ['-a'],
    ['--all'],
    [],
    ' ARG',
    'description of option',
    :string,
    ->(arg) { arg }
  )

  assert('with short and long options') do
    expected = '-a, --all ARG                     description of option'
    assert_equal expected, switch.summarize, 'should format short and long options correctly'
  end

  assert('with skip short options') do
    expected = '    --all ARG                     description of option'
    assert_equal expected, switch.summarize(['-a']), 'should skip specified options'
  end

  assert('with indent') do
    expected = '    -a, --all ARG                     description of option'
    assert_equal expected, switch.summarize([], '    '), 'should apply indent correctly'
  end

  assert('with custom width') do
    expected = '-a, --all ARG                             description of option'
    assert_equal expected, switch.summarize([], '', 40), 'should apply custom width correctly'
  end

  assert('without description') do
    switch = OptionParser::Switch.new(
      ['-a'],
      ['--all'],
      [],
      ' ARG',
      nil,
      :string,
      ->(arg) { arg }
    )
    expected = '-a, --all ARG                   '
    assert_equal expected, switch.summarize, 'should format without description'
  end
end
