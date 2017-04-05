require 'rspec'

class GenerationTestCase
  def initialize(router)
    @router = router
  end

  def run!(tests)
    _run! :path, tests
    _run! :url,  tests
  end

  private
  def _run!(type, tests)
    _for_each_test(type, tests) do |actual, expected|
      expect(actual).to eq(expected)
    end
  end

  def _for_each_test(type, tests)
    tests.each do |test|
      name, expected, args = *test
      args = args.dup rescue nil

      _rescue name, expected, args do
        actual   = _actual(type, name, args)
        expected = _expected(type, expected)

        yield actual, expected
      end
    end
  end

  def _rescue(name, expected, args)
    begin
      yield
    rescue Exception => e
      puts "Failed with #{ name }, #{ expected.inspect }, #{ args.inspect }"
      raise e
    end
  end

  def _actual(type, name, args)
    case args
    when Hash
      @router.send(type, name, args)
    when Array
      var, a = *args
      @router.send(type, name, *[var, a].flatten.compact)
    when NilClass
      @router.send(type, name)
    else
      raise args.inspect
    end
  end

  def _expected(type, expected)
    if type == :url
      _absolute(expected)
    else
      expected
    end
  end

  def _absolute(expected)
    "http://localhost#{ expected }"
  end
end
