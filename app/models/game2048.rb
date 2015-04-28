class Game2048 < ActiveRecord::Base
    # TODO: How do we actually interact with ActiveRecord?
    def self.getBoard
        state = Game2048.take
        puts state
    end

    # TODO: Write this!
    def self.move()
    end
end
