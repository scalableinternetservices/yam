module UsersHelper
  def cache_key_for_profile(user)
	"profile-#{user.updated_at}"
  end

  def cache_key_for_gamer_tag(user)
	"profile-#{user.email}-#{user.gamer_tag}"
  end

end
