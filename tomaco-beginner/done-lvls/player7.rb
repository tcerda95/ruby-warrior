
require './action'

class Player
    MAX_HP = 20
    REST_HP = 9
    MAX_ENEMIES = 2
    MAX_CAPTIVES = 0
    RETREAT_ENEMIES = 1

    def initialize
        @environment = Environment.new(MAX_ENEMIES, MAX_CAPTIVES)
        @status = Status.new(MAX_HP)
        @actions = [EnemyDefeatedAction.new, RestAction.new(REST_HP), AttackAction.new, RescueAction.new, PivotAction.new, WalkAction.new] # Order inside array indicates priority
    end

    def play_turn(warrior)
        @environment.scan(warrior)
        @status.scan(warrior)
        action = @actions.find {|a| a.should_exec?(@environment, @status)}
        raise "No suitable action to execute" if action.nil?
        action.exec(warrior)
    end

end

class Status
    attr_reader :health

    def initialize(health)
        @health = health
    end

    def took_dmg?
        @prev_health > @health
    end

    def lost_dmg
        took_dmg? ? @prev_health - @health : 0
    end

    def scan(warrior)
        @prev_health = @health
        @health = warrior.health
    end
end

class Sensor
    DIRS = [:forward, :right, :backward, :left]

    attr_reader :count, :dirs

    def initialize(scanner)
        @scanner = scanner
        @count = 0
    end

    def scan(warrior)
        @prev_count = @count
        @dirs = DIRS.select {|d| @scanner.call(warrior.feel(d))}
        @count = @dirs.length
    end

    def subject_dealt?
        @prev_count > @count
    end

    def subject_nearby?
        @count > 0
    end

    def subject_dir? dir
        @dirs.include? dir
    end
end

class Environment
    attr_reader :enemies, :captives 

    def initialize(enemies, captives)
        @enemies = enemies
        @captives = captives

        enemy_sensor = Sensor.new(Proc.new {|space| space.enemy?})
        captive_sensor = Sensor.new(Proc.new {|space| space.captive?})
        wall_sensor = Sensor.new(Proc.new {|space| space.wall?})

        @sensors = {enemy_sensor: enemy_sensor, captive_sensor: captive_sensor, wall_sensor: wall_sensor}
    end

    def scan(warrior)
        @sensors.each_value {|sensor| sensor.scan(warrior)}
        @enemies -= 1 if enemy_sensor.subject_dealt?
        @captives -= 1 if captive_sensor.subject_dealt?
    end

    def sensors
        @sensors.values
    end

    def enemy_sensor
        @sensors[:enemy_sensor]
    end

    def captive_sensor
        @sensors[:captive_sensor]
    end

    def wall_sensor
        @sensors[:wall_sensor]
    end
end
