# frozen_string_literal: true

class TestApp
  def call(env)
    [ 200, {'Content-Type' => 'text/html'}, ['Hello World!'] ]
  end
end