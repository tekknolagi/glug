require 'sinatra'
require 'cgi'
require 'base64'
require './database'

$num_posts = 15

class GulagApp < Sinatra::Application
  include FileUtils::Verbose

  helpers do
    def current_page
      request.path_info
    end

    def h(html)
      CGI.escapeHTML html
    end
    
    def bad(content)
      content == nil or content == "" or content.length < 2 or content =~ /^\s*$/
    end

    def tracking_url
      ENV['GULAG_TRACKING_URL']
    end

    def num_posts
      $num_posts
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
    if bad(params[:post])
      redirect to(params[:orig] || "/")
    end

    if bad(params[:author])
      params[:author] = nil
    else
      params[:author] = params[:author].chomp
    end

    params[:post] = params[:post][0..1000].gsub(/\s\w+\s*$/, '...')
    params[:comment] = params[:comment][0..1000].gsub(/\s\w+\s*$/, '...')

    p = Post.new(:title => params[:post], :author => params[:author])
    if params[:comment][-5..-1] == ENV['GULAG_ADMIN_PASSWORD']
      c = Comment.new(:body => params[:comment][0...-5], :admin => true)
    else
      c = Comment.new(:body => params[:comment])
    end
    p.comments << c
    if params[:image] && params[:image][:tempfile]
      i = ImageUploader.new
      i.store! params[:image]
      p.image = Image.create(:url => i.url, :thumb => i.thumb.url)
      p.save!
    end
    p.save!
    old_p = Post.all[0-num_posts-1]
    begin
      old_p.destroy!
    rescue
    end
    redirect to("/p/#{p.uid}")
  end

  post '/p/:uid' do
    if bad(params[:body])
      redirect to(params[:orig])
    end

    params[:comment] = params[:comment][0..1000].gsub(/\s\w+\s*$/, '...')

    if params[:body][-5..-1] == ENV['GULAG_ADMIN_PASSWORD']
      c = Comment.new(:body => params[:body][0...-5], :admin => true)
    else
      c = Comment.new(:body => params[:body])
    end
    @post = Post.first(:uid => params[:uid])
    @post.comments << c
    c.save
    redirect to(params[:orig])
  end
end
