class TestEndpoint
  def call(env)
    'Hi from TestEndpoint!'
  end
end #TestEndpoint

class TestController
  class Show
    def call(env)
      'Hi from Test::Show!'
    end
  end
end #TestController

class TestApp
  class TestEndpoint
    def call(env)
      'Hi from TestApp::TestEndpoint!'
    end
  end

  class Test2Controller
    class Show
      def call(env)
        'Hi from TestApp::Test2Controller::Show!'
      end
    end
  end
end # TestApp

class AvatarController
  class New
    def call(env)
      [200, {}, ['Avatar::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Avatar::Create']]
    end
  end

  class Show
    def call(env)
      [200, {}, ['Avatar::Show']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Avatar::Edit']]
    end
  end

  class Update
    def call(env)
      [200, {}, ['Avatar::Update']]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['Avatar::Destroy']]
    end
  end
end # AvatarController

class ProfileController
  class Show
    def call(env)
      [200, {}, ['Profile::Show']]
    end
  end

  class New
    def call(env)
      [200, {}, ['Profile::New']]
    end
  end

  class Create
    def call(env)
      [200, {}, ['Profile::Create']]
    end
  end

  class Edit
    def call(env)
      [200, {}, ['Profile::Edit']]
    end
  end

  class Update
    def call(env)
      [200, {}, ['Profile::Update']]
    end
  end

  class Destroy
    def call(env)
      [200, {}, ['Profile::Destroy']]
    end
  end

  class Activate
    def call(env)
      [200, {}, ['Profile::Activate']]
    end
  end

  class Keys
    def call(env)
      [200, {}, ['Profile::Keys']]
    end
  end
end # ProfileController

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

  class Search
    def call(env)
      [200, {}, ['Keyboards::Search']]
    end
  end

  class Screenshot
    def call(env)
      [200, {}, ['Keyboards::Screenshot ' + env['router.params'][:id]]]
    end
  end
end # KeyboardsController
