require './conf/boot.rb'
require 'app'

#use Rack::CommonLogger, LOGGER

$stdout.sync = true

run App