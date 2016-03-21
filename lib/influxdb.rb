require 'influxdb'


  database = 'site_development'
name = 'foobar'
influxdb = InfluxDB::Client.new host: "localhost", database: database
#  influxdb.create_database(database)

Value = (0..360).to_a.map {|i| Math.send(:sin, i / 10.0) * 10 }.each

loop do
  data = {
    values: { value: Value.next },
    tags: { wave: 'sine' } # tags are optional
  }

  influxdb.write_point(name, data)

  sleep 1
end

