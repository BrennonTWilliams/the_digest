module SessionsHelper

	# Log a user in after authenticating, store in session
	def log_in user
		session[:user_id] = user.id
	end

	# Return the currently logged in user for this session
	def current_user
		if !@current_user
			@current_user =  User.find_by(id: session[:user_id])
		end
		@current_user
		# @current_user ||= User.find_by(id: session[:user_id])
	end

	# Log out for a user
	def log_out
		session[:user_id] = nil
	end

end
