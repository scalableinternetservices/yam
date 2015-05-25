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
end
