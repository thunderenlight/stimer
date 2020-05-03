class TwilioController < ApplicationController
	skip_before_action :verify_authenticity_token

	def trigger_update
	end

	def sms
		from = params[:From].gsub(/^\+\d/, '')

		@timer = Timer.find_by(name: "work")
		@timer.trigger_update
		time = @timer.time
		str_time = ((time).localtime).strftime("%I:%M%p on %b. %d, %Y")
		user = @timer.name

		response = Twilio::TwiML::MessagingResponse.new do |r|
			r.message body: "Hey #{user} at #{from} your next reminder is at #{str_time}"
		end
		render xml: response.to_s
	end

end