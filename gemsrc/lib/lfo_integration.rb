require 'net/http'
require 'uri'
require 'json'

# The program provides scoring advice about consumers 
# given their income, zipcode, and age.
#
# Author::    Frederick Wells  
# Copyright:: Copyright (c) 2013 Not Really
# License::   XXX

class LfoIntegration
	attr_accessor :income, :zipcode, :age, :code, :propensity, :ranking, :message, :base_url
	
	#constructor income, zipcode, age are required. you can override the base_url 
	def initialize(params)
		@income = params[:income]
		@zipcode = params[:zipcode]
		@age = params[:age] 
		raise TypeError unless @income.is_a?(Numeric)
		raise TypeError unless @:zipcode.is_a?(Numeric)
		raise TypeError unless @:age.is_a?(Numeric)
		@base_url = params.fetch(:base_url, 'http://internal.leapfrogonline.com/customer_scoring')
	end
	
	#gets response from advice API
	def get_advice?
		@ranking = @propensity = nil
		q_string = query_string
		full_string = "#{@base_url}#{q_string}"
		uri = URI.parse(full_string)
		begin
			response = Net::HTTP.get_response(uri)
			code = response.code.to_i
			response_ok = code == 200
			set_message(code)
		rescue SocketError => e
			@message = e.message
			response_ok = false
		end
		if(response_ok)
			body = JSON.parse(response.body)
			@propensity = body['propensity']
			@ranking = body['ranking']
		end
		return response_ok
	end
	
	#sets the response message
	def set_message(code)
		if(code == 200)
			@message = 'ok'
		elsif(code == 404)
			@message = 'The resource wasn\'t found.'
		elsif(code == 500)
			@message = 'An error occured.'
		else
			@message = 'Unknown error.'
		end
	end
	
	#builds query string
	def query_string
		return "?income=#{@income}&zipcode=#{@zipcode}&age=#{@age}"
	end
end