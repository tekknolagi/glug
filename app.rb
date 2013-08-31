require 'sinatra'
require 'data_mapper'
require 'cgi'
require 'base64'

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
  has 1, :image
end

class Comment
  include DataMapper::Resource

  property :id, Serial
  property :uid, String, :length => 32, :default => lambda { |r, p| Digest::MD5.hexdigest(r.created_at.to_s+r.body) }
  property :body, Text
  property :created_at, DateTime, :default => ->(r, p) { DateTime.now }

  def nicedate
    created_at.strftime("%I:%M%P on %A %B %d, %Y")
  end

  has 1, :image
end

class Image
  include DataMapper::Resource

  property :id, Serial
  property :uid, String, :length => 32, :default => lambda { |r, p| Digest::MD5.hexdigest(r.created_at.to_s+r.file) }
  property :file, Text
  property :type, String
  property :created_at, DateTime, :default => ->(r, p) { DateTime.now }

  belongs_to :comment, :required => false
  belongs_to :post, :required => false
end

DataMapper.auto_upgrade!

def h(html)
  CGI.escapeHTML html
end

def bad(content)
  content == nil or content == "" or content.length < 2 or content =~ /^\s*$/
end

class GulagApp < Sinatra::Application
  include FileUtils::Verbose

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

  get '/i/:uid' do
    if (i = Image.first(:uid => params[:uid]))
      response.headers['Content-Type'] = i.type
      Base64.decode64(i.file)
    else
      Base64.decode(File.read("404.txt"))
    end
  end

  post '/new' do
    if bad(params[:post]) or bad(params[:comment])
      puts params[:post]
      puts params[:comment]
      redirect to(params[:orig] || "/")
    end
    if params[:image] && params[:image][:tempfile]
      @file = true
      b64 = [File.read(params[:image][:tempfile])].pack("m")
      puts b64
      i = Image.create(:file => b64, :type => params[:image]['Content-Type'])
      puts i
    end
    p = Post.create(:title => params[:post])
    c = Comment.new(:body => params[:comment])
    p.comments << c
    c.save
    if @file
      p.image = i
      i.save
    end
    redirect to("/p/#{p.uid}")
  end

  post '/p/:uid' do
    if bad(params[:body])
      redirect to(params[:orig])
    end
    @post = Post.first(:uid => params[:uid])
    c = Comment.create(:body => params[:body])
    @post.comments << c
    c.save
    redirect to(params[:orig])
  end
end
