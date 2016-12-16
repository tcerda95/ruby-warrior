
# The health necessary to defeat a BigSludge is 13.
# Check health if not fighting and rest if health below 13.

class Player
    REST_HP = 13
    MAX_ENEMIES = 3

    def play_turn(warrior)
        if !@init
            @init = true
            @enemies = 3
            @health = Health.new(warrior)
        end

        @health.start_turn
        @space = warrior.feel

        @enemies -= 1 if enemy_defeated?

        @attacked = false

        if should_rest?
            warrior.rest!
        elsif should_fight?
            @attacked = true
            warrior.attack!
        elsif should_rescue?
            warrior.rescue!
        else
            warrior.walk!
        end
    end

    private

    def should_rest?
        !@space.enemy? && @health.health < REST_HP && !@health.took_dmg? && @enemies > 0
    end

    def should_fight?
        @space.enemy?
    end

    def should_rescue?
        @space.captive?
    end

    def enemy_defeated?
        @attacked  && !@space.enemy?
    end
end

class Health
    MAX_HEALTH = 20

    attr_reader :health

    def initialize(warrior)
        @warrior = warrior
        @health = MAX_HEALTH
    end

    def start_turn
        @prev_health = @health
        @health = @warrior.health
    end

    def took_dmg?
        @prev_health > @health
    end

    def lost_dmg
        took_dmg? ? @prev_health - @health : 0
    end
end
