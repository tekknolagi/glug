require 'sinatra'

class GulagApp < Sinatra::Application
  get '/' do
    "hi"
  end
end
