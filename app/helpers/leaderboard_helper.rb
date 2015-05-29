module LeaderboardHelper
  def cache_key_for_leaderboard
	"leaderboard-#{User.maximum(:updated_at)}"
  end

  def cache_key_for_leader_row(l)
	"leaderboard-row-#{l.id}-#{l.rating}-#{l.updated_at}"
  end
end


