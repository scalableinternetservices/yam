class StaticPagesController < ApplicationController
  def home
    expires_in 24.hours, public: true
  end

  def about
    expires_in 24.hours, public: true
  end

  def battle_2048_instructions
    expires_in 24.hours, public: true
  end

  def leaderboard
    new_leaders = User.all.order(rating: :desc).limit(50)
    @leaders = new_leaders if stale?(new_leaders)
  end
end
