module ApplicationHelper
  def cache_key_for_navigation
	"navigation-bar-#{Time.now.to_i}"
  end
end
