require 'yaml'

config_influxdb = YAML.load_file('conf/database.yaml')
config_redis = YAML.load_file('conf/redis.yaml')
		
if @environment == 'production'
	$influxdb_server = config_influxdb['influxdb_production']['server']
	$influxdb_username = config_influxdb['influxdb_production']['username']
	$influxdb_password = config_influxdb['influxdb_production']['password']
	$influxdb_database = config_influxdb['influxdb_production']['databasename']
	$influxdb_port = config_influxdb['influxdb_production']['port']

	$REDIS_HOST = config_redis['production']['server']
	$REDIS_PORT = config_redis['production']['port']
elsif @environment == 'staging'
	$influxdb_server = config_influxdb['influxdb_staging']['server']
	$influxdb_username = config_influxdb['influxdb_staging']['username']
	$influxdb_password = config_influxdb['influxdb_staging']['password']
	$influxdb_database = config_influxdb['influxdb_staging']['databasename']
	$influxdb_port = config_influxdb['influxdb_staging']['port']

	$REDIS_HOST = config_redis['staging']['server']
	$REDIS_PORT = config_redis['staging']['port']
else
	$influxdb_server = config_influxdb['influxdb_development']['server']
	$influxdb_username = config_influxdb['influxdb_development']['username']
	$influxdb_password = config_influxdb['influxdb_development']['password']
	$influxdb_database = config_influxdb['influxdb_development']['databasename']
	$influxdb_port = config_influxdb['influxdb_development']['port']

	$REDIS_HOST = config_redis['development']['server']
	$REDIS_PORT = config_redis['development']['port']
end