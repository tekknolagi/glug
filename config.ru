require './app.rb'
require 'thin'

GulagApp::Application.config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
  r301 %r{.*}, 'http://glug.bernsteinbear.com$&', :if => Proc.new {|rack_env|
    rack_env['SERVER_NAME'] != 'glug.bernsteinbear.com'
  }
end

run GulagApp
