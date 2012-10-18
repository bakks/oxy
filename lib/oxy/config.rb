require 'yaml'
require 'hash_deep_merge'

$configfile = File.dirname(__FILE__) + '/../../config.yml'
$log.info "loading config from #{$configfile}"

conf = YAML.load_file($configfile)

$config = conf['all'] or {}
$config.deep_merge! conf[$env] if conf[$env]

