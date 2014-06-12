module Api
  class App
    def call(env)
      case env['PATH_INFO']
      when '/'
        [200, {}, ['home']]
      when '/articles'
        [200, {}, ['articles']]
      else
        [404, {}, ['Not Found']]
      end
    end
  end
end

module Backend
  class App
    def self.call(env)
      [200, {}, ['home']]
    end
  end
end

class DashboardController
  class Index
    def call(env)
      [200, {}, ['dashboard']]
    end
  end
end
