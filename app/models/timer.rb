class Timer < ApplicationRecord

	validates :name, :phone_number, :time, presence: true

	after_save :reminder
	after_create :preset_update

	
	def credentials
		@twilio_number = Rails.application.secrets.TWILIO_NUMBER
		account_sid = Rails.application.secrets.TWILIO_ACCOUNT_SID
		auth_token = Rails.application.secrets.TWILIO_AUTH_TOKEN
		@client = Twilio::REST::Client.new account_sid, auth_token
	end


	def reminder
		credentials()
		time_str = ((self.time).localtime).strftime("%I:%M%p on %b. %d, %Y")
		time_now = Time.now
		body = "Hi #{self.name}. Just a reminder that you have a new cooking step at #{time_str}.
				Reply with a number anumber in minutes to start a new reminder."
		message = @client.messages.create(
			:from => @twilio_number,
			:to => self.phone_number,
			:body => body
		)
	end

	def msgs
		credentials()
		@next_time = [] 	
		@messages = @client.messages.list(
        
        from: self.phone_number
		)
		@messages.each do |rec|
			@next_time << rec.body
			
		end
		return @next_time
	end

	def time_to_remind() 
 		
 		@new_time = msgs.first

 	end

 	def trigger_update
 		min = time_to_remind.to_i
 		advance = Time.new.advance(minutes: min)
 		self.update_attributes!(time: advance)
 		return self.time
 	end
 	def preset_update
 		#hash of step, times steps = step.times do an update with step[time]=min
 		if self.name.strip == "breadmaker"
	 		min = 7
	 		advance = self.time.advance(minutes: min)
	 		self.update_attributes!(time: advance)
	 		return self.time
 		end
 	end
 		

	def when_to_run
		minutes_before_appointment = 2.minutes
		time - minutes_before_appointment
	
	end

	def preset_when_to_run
		self.time + 1.minutes
	end

	handle_asynchronously :reminder, :run_at => Proc.new { |i| i.when_to_run }

	handle_asynchronously :preset_update, :run_at => Proc.new { |i| i.preset_when_to_run }


	
end
