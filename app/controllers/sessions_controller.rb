class SessionsController < ApplicationController

	def new
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_back_or user
		else
			flash.now[:error] = "Invalid email/password combination" #.now тільки на 1 загрузку сторінки (Див.8.1.5)
			render 'new'
		end
	end

	def destroy
		sign_out if signed_in?
		redirect_to root_path
	end
end
