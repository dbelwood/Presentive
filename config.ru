require './conf/boot.rb'
require 'app'

use Rack::CommonLogger, LOGGER

run App