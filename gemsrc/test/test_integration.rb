require 'test/unit'
require '../lfo_integration'

class TestIntegration < Test::Unit::TestCase
	def setup
		@lfo = LfoIntegration.new(:income => 50000,:zipcode => 60201,:age => 45, :base_url => 'http://localhost:4567/customer_scoring');
	end
	
	def teardown
	end
	
	def test_init
		assert_equal(50000, @lfo.income)
		assert_equal(60201, @lfo.zipcode)
		assert_equal(45, @lfo.age)
	end
	
	def test_exception_raise
		assert_raise( TypeError ) { LfoIntegration.new(:income => '50000',:zipcode => 60201,:age => 45, :base_url => 'http://localhost:4567/customer_scoring') }
		assert_raise( TypeError ) { LfoIntegration.new(:income => 50000,:zipcode => '60201',:age => 45, :base_url => 'http://localhost:4567/customer_scoring') }
		assert_raise( TypeError ) { LfoIntegration.new(:income => 50000,:zipcode => 60201,:age => '45', :base_url => 'http://localhost:4567/customer_scoring') }
	end
	
	def test_query_string
		assert_equal('?income=50000&zipcode=60201&age=45', @lfo.query_string)
	end
	
	# These next tests are based off of running the Sinatra test server.
	# setting the age to 33 generates a 404 response
	# setting the age to 34 generates a 500 response
	# any other values sent to the Sinatra server will return
	# a JSON with {"propensity" : "0.26532","ranking" : "C"}
	def test_error_response
		@lfo.age = 33
		@lfo.get_advice?
		assert_equal('The resource wasn\'t found.', @lfo.message)
		assert_nil(@lfo.ranking)
		assert_nil(@lfo.propensity)
		@lfo.age = 34
		@lfo.get_advice?
		assert_equal('An error occured.', @lfo.message)
		assert_nil(@lfo.ranking)
		assert_nil(@lfo.propensity)
	end
	
	def test_valid_response
		@lfo.get_advice?
		assert_equal('ok', @lfo.message)
		assert_equal('0.26532', @lfo.propensity)
		assert_equal('C', @lfo.ranking)
	end
	
	def test_error_then_valid_response
		@lfo.age = 33
		@lfo.get_advice?
		assert_equal('The resource wasn\'t found.', @lfo.message)
		assert_nil(@lfo.ranking)
		assert_nil(@lfo.propensity)
		@lfo.age = 45
		@lfo.get_advice?
		assert_equal('ok', @lfo.message)
		assert_equal('0.26532', @lfo.propensity)
		assert_equal('C', @lfo.ranking)
	end
	
	def test_valid_then_error_response
		@lfo.age = 45
		@lfo.get_advice?
		assert_equal('ok', @lfo.message)
		assert_equal('0.26532', @lfo.propensity)
		assert_equal('C', @lfo.ranking)
		@lfo.age = 33
		@lfo.get_advice?
		assert_equal('The resource wasn\'t found.', @lfo.message)
		assert_nil(@lfo.ranking)
		assert_nil(@lfo.propensity)
	end
end