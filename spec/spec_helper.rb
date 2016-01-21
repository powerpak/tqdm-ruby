RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

def with_stderr(&block)
  old_stderr = $stderr
  $stderr    = StringIO.new

  block.call

  return $stderr.string
ensure
  $stderr = old_stderr
end