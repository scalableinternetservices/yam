class StaticPagesController < ApplicationController
  def home
    expires_in 24.hours, public: true
  end

  def about
    expires_in 24.hours, public: true
  end

  def profile
  end

  def tictactoe
  end
end
