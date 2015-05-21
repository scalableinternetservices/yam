# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

0.upto(1000) do |n|
  User.create(email: "test#{n}@test.com", encrypted_password: "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3") 
  # Game2048.create(pid1: n, pid2: n + 1000,
  #               board1: Board.new.to_s, board2: Board.new.to_s, player1turn: true)
end
