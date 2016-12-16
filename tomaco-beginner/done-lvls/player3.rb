
# The health necessary to defeat a Sludge is 7.
# Check health if not fighting and rest if health below 7 and no enemies left.

class Player
    REST_HP = 7

    def play_turn(warrior)
        @space = warrior.feel
        @health = warrior.health

        if should_rest?
            warrior.rest!
        elsif should_fight?
            warrior.attack!
        else
            warrior.walk!
        end
    end

    private

    def should_rest?
        !@space.enemy? && @health < REST_HP
    end

    def should_fight?
        @space.enemy?
    end
end
