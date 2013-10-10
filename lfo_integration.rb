require 'net/http'
require 'uri'
require 'json'

class LfoIntegration
	attr_accessor :income, :zipcode, :age, :code, :propensity, :ranking, :message, :base_url
	
	def initialize(params)
		raise TypeError unless params[:income] .is_a?(Numeric)
		raise TypeError unless params[:zipcode].is_a?(Numeric)
		raise TypeError unless params[:age].is_a?(Numeric)
		@income = params[:income] || raise('income parameter is required')
		@zipcode = params[:zipcode] || raise('zipcode parameter is required')
		@age = params[:age] || raise('age parameter is required')
		@base_url = params.fetch(:base_url, 'http://internal.leapfrogonline.com/customer_scoring')
	end
	
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
	
	def query_string
		return "?income=#{@income}&zipcode=#{@zipcode}&age=#{@age}"
	end
end