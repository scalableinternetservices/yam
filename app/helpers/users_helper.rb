module UsersHelper
  def cache_key_for_profile(user)
	"profile-#{user.updated_at}"
  end

  def cache_key_for_gamer_tag(user)
	"profile-#{user.email}-#{user.gamer_tag}"
  end

  def cache_key_for_image(user)
	"profile-#{user.email}-#{user.profile_image}"
  end

  def cache_key_for_profile_info(user)
	"profile-#{user.email}-#{user.last_sign_in_at}-#{user.rating}-#{user.gamer_tag}"
  end

end
