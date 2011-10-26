# Add /lib to load path
libdir = File.join(File.dirname(__FILE__), '../lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

ENV['RACK_ENV'] ||= 'development'

# Configure logging

require 'logger'
LOGGER = Logger.new(File.join(File.dirname(__FILE__), "/../log/#{ENV['RACK_ENV']}.log"))

# Load Mongoid
require 'mongoid'
ENV['MONGOHQ_URI'] = ''
Mongoid.load!(File.join(File.dirname(__FILE__), "/mongoid.yml"))
Mongoid.logger = LOGGER unless (ENV['RACK_ENV'] == 'production')

# Configure Carrierwave to use Mongoid
mongoid_settings = YAML::load(File.open(File.join(File.dirname(__FILE__), "/mongoid.yml")))

require 'carrierwave/mongoid'
CarrierWave.configure do |config|
  config.grid_fs_database = mongoid_settings[ENV['RACK_ENV']]["database"]
  config.grid_fs_host = mongoid_settings[ENV['RACK_ENV']]["hostname"]
  config.grid_fs_access_url = "/images"
end
