require 'data_mapper'
require 'carrierwave'
require 'carrierwave/datamapper'
require 'tzinfo'

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_NAVY_URL'] || ENV['GULAGRB_POSTGRESQL_URL'])

class Post
  include DataMapper::Resource

  property :id, Serial
  property :uid, String, :length => 32, :default => lambda { |r, p| Digest::MD5.hexdigest(r.created_at.to_s+r.title) }
  property :title, String
  property :author, String
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
  property :admin, Boolean, :default => false

  def to_pst
    tz = TZInfo::Timezone.get('America/Los_Angeles')
    tz.utc_to_local(created_at.to_time).to_datetime
  end

  def nicedate
    to_pst.strftime("%I:%M%P on %A %B %d, %Y")
  end

  has 1, :image
end


CarrierWave.configure do |config|
   config.fog_credentials = {
    :provider           => 'Rackspace',
    :rackspace_username => ENV['RACKSPACE_USER'],
    :rackspace_api_key  => ENV['RACKSPACE_API_KEY']
  }
  config.fog_directory = ENV['RACKSPACE_CONTAINER']
  config.asset_host = ENV['RACKSPACE_ASSET_HOST']

  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  process :set_content_type
  storage :fog

  def store_dir
    "uploads"
  end
  
  version :thumb do
    process :resize_to_fill => [200,132]
  end
end

class Image
  include DataMapper::Resource
  extend CarrierWave::Mount

  mount_uploader :source, ImageUploader

  property :id, Serial
  property :created_at, DateTime, :default => ->(r, p) { DateTime.now }

  property :url, Text, :length => 200
  property :thumb, Text, :length => 200

  belongs_to :comment, :required => false
  belongs_to :post, :required => false
end

DataMapper.auto_upgrade!
