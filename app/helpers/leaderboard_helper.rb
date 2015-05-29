module LeaderboardHelper
=begin
  def cache_key_for_leaderboard
	"leaderboard-#{Users.maximum(:updated_at)}"
  end
=end

  def cache_key_for_leader_row(l)
	"leaderboard-row-#{l.id}-#{l.rating}-#{l.updated_at}"
  end
end


