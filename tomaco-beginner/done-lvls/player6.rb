
class Player
    REST_HP = 16
    MAX_ENEMIES = 3
    MAX_CAPTIVES = 1
    RETREAT_ENEMIES = 1

    def initialize
        @enemies = MAX_ENEMIES
        @health = Health.new
        @attack_action = Action.new(MAX_ENEMIES, Proc.new { |space| space.enemy? }, Proc.new { |w, dir| w.attack! (dir) })
        @rescue_action = Action.new(MAX_CAPTIVES, Proc.new { |space| space.captive? }, Proc.new { |w, dir| w.rescue! (dir) })
    end

    def play_turn(warrior)
        @health.warrior = warrior
        @attack_action.warrior = warrior
        @rescue_action.warrior = warrior

        @space = warrior.feel

        if enemy_defeated?
            @enemies -= 1
            warrior.walk! (@enemies > RETREAT_ENEMIES ? :backward : :forward)
        elsif should_rest?
            warrior.rest!
        elsif @attack_action.should_exec?
            @attack_action.exec
        elsif @rescue_action.should_exec?
            @rescue_action.exec
        elsif @rescue_action.count > 0
            warrior.walk! :backward
        else
            warrior.walk!
        end
    end

    private

    def should_rest?
        @health.health < REST_HP && !@health.took_dmg? && @enemies > 0
    end

    def enemy_defeated?
        @attack_action.count < @enemies
    end
end

class Action
    DIRS = [:forward, :right, :backward, :left]

    attr_reader :count

    def initialize (count, scanner, action)
        @count, @scanner, @action = count, scanner, action
        @action_exec = false
    end

    def should_exec?
        @dir = DIRS.find { |d| @scanner.call (@warrior.feel (d)) }
        !@dir.nil?
    end

    def exec
        raise "No direction found by should_exec? or method not called." if @dir.nil?
        @action.call(@warrior, @dir)
    end

    def warrior=(warrior)
        @warrior = warrior

        if !@dir.nil?
            @count -= 1 if !(@scanner.call (@warrior.feel(@dir)))
            @dir = nil
        end
    end
end

class Health
    MAX_HEALTH = 20

    attr_reader :health

    def initialize
        @health = MAX_HEALTH
    end

    def took_dmg?
        @prev_health > @health
    end

    def lost_dmg
        took_dmg? ? @prev_health - @health : 0
    end

    def warrior=(warrior)
        @warrior = warrior
        @prev_health = @health
        @health = @warrior.health
    end
end
