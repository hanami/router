class TestEndpoint
end #TestEndpoint

class TestController
  class Show
  end
end #TestController

class TestApp
  class TestEndpoint
  end

  class Test2Controller
    class Show
    end
  end
end # TestApp

class FlowersController
  class Index
    def call(env)
      [200, {}, ['Flowers::Index']]
    end
  end

  class New
    def call(env)
      [200, {}, ['Flowers::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Flowers::Create']]
    end
  end

  class Show
    def call(env)
      [200, {}, ['Flowers::Show ' + env['router.params'][:id]]]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Flowers::Edit ' + env['router.params'][:id]]]
    end
  end

  class Update
    def call(env)
      [200, {}, ['Flowers::Update ' + env['router.params'][:id]]]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['Flowers::Destroy ' + env['router.params'][:id]]]
    end
  end
end # FlowersController

class KeyboardsController
  class Index
    def call(env)
      [200, {}, ['Keyboards::Index']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Keyboards::Create']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Keyboards::Edit ' + env['router.params'][:id]]]
    end
  end
end # KeyboardsController
