# frozen_string_literal: true

class TestApp
  def call(env)
    [200, { 'content-type' => 'text/html' }, ['Hello World!']]
  end
end