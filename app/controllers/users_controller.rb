class UsersController < ApplicationController
	# Controller to handle user profiles
	def show
		@user = User.find(params[:id]) if stale?(current_user)
	end
end
