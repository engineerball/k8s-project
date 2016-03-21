require 'json'
require 'workers'
require_relative 'heapster'

class MetricAgent

  @scheduler
	def initialize(auth_options)
		@auth_options = auth_options
		@heapster = Heapster.new auth_options
		pool = Workers::Pool.new(:size => 100)
		@scheduler = Workers::Scheduler.new(:pool => pool)

	end

	def handleAgent(client)
    loop do
			@heapster.send(:client)
			sleep 60
    end
  end

	def startAgent(functionname)      
  	timer = Workers::PeriodicTimer.new(1) do
  		puts 'Hello world many times'
		end
		sleep 10
	end

	def test_function
		chan = channel!(Integer)

		#go routine
		go! do
		  puts 'hello, world!'
		end

		#wait around
		loop do
			sleep 60
			puts 'b'
		end
	end
end