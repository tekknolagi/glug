require 'sinatra'
require 'data_mapper'
require 'CGI'

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_NAVY_URL'] || ENV['GULAGRB_POSTGRESQL_URL'])

class Post
  include DataMapper::Resource

  property :id, Serial
  property :uid, String, :length => 32, :default => lambda { |r, p| Digest::MD5.hexdigest(r.created_at.to_s+r.title) }
  property :title, String
  property :created_at, DateTime, :default => ->(r, p) { DateTime.now }

  def nicedate
    created_at.strftime("%I:%M%P on %A %B %d, %Y")
  end

  has n, :comments
end

class Comment
  include DataMapper::Resource

  property :id, Serial
  property :uid, String, :length => 32, :default => lambda { |r, p| Digest::MD5.hexdigest(r.created_at.to_s+r.body) }
  property :body, String
  property :created_at, DateTime, :default => ->(r, p) { DateTime.now }

  def nicedate
    created_at.strftime("%I:%M%P on %A %B %d, %Y")
  end
end

DataMapper.auto_upgrade!

def h(html)
  CGI.escapeHTML html
end

class GulagApp < Sinatra::Application
  helpers do
    def current_page
      request.path_info
    end
  end

  get '/' do
    @orig = current_page
    erb :index
  end

  get '/p/:uid' do
    @orig = current_page
    @post = Post.first(:uid => params[:uid])
    erb :single
  end

  post '/new' do
    p = Post.create(:title => params[:post])
    c = Comment.new(:body => params[:comment])
    p.comments << c
    c.save
    redirect to("/p/#{p.uid}")
  end

  post '/p/:uid' do
    @post = Post.first(:uid => params[:uid])
    c = Comment.create(:body => params[:body])
    @post.comments << c
    c.save
    redirect to(params[:orig])
  end
end
