#\ -p 4000

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Missing dependencies. Run `bundle install` to install missing gems."
  exit e.status_code
end

require 'tipsy'
require 'sprockets'

# Setup the root path and initialize.
Tipsy.root = ::File.dirname(__FILE__) + "/test/root"
use Rack::CommonLogger
use Rack::ShowStatus
use Rack::ShowExceptions
run Rack::Cascade.new([
	Rack::URLMap.new({ "/assets" => Tipsy::AssetHandler.new }),
	Tipsy::Server.new,
	Rack::Directory.new(Tipsy.root + '/public')
])