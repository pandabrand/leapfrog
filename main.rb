require 'sinatra'
require 'json'

get '/' do
	'nothing here'
end

get '/customer_scoring' do
	@income = params[:income]
	@zip = params[:zipcode]
	@age = params[:age]
	
	if @age.to_i == 33
		404
	elsif @age.to_i == 34
		500
	else
		content_type :json
		{:propensity => '0.26532', :ranking => 'C'}.to_json
	end
end