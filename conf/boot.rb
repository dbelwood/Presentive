# Add /lib to load path
libdir = File.join(File.dirname(__FILE__), '../lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

ENV['RACK_ENV'] ||= 'development'

# Load Mongoid
require 'mongoid'
#ENV['MONGOHQ_URI'] = 'mongodb://heroku:b002764d51c0524e8f45fcd88cda3c1c@staff.mongohq.com:10028/app1609127'
Mongoid.load!(File.join(File.dirname(__FILE__), "/mongoid.yml"))
#Mongoid.logger = LOGGER unless (ENV['RACK_ENV'] == 'production')

# Configure Carrierwave to use Mongoid
mongoid_settings = YAML::load(File.open(File.join(File.dirname(__FILE__), "/mongoid.yml")))

require 'carrierwave/mongoid'
CarrierWave.configure do |config|
  config.grid_fs_connection = Mongoid.database
  config.grid_fs_access_url = "/images"
  config.cache_dir = File.join(File.dirname(__FILE__), '../tmp')
end
