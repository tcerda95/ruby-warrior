
require './action'

class Player
    MAX_HP = 20
    REST_HP = 9
    MAX_ENEMIES = 2
    MAX_CAPTIVES = 1
    RETREAT_ENEMIES = 1

    def initialize
        @environment = Environment.new(MAX_ENEMIES, MAX_CAPTIVES)
        @status = Status.new(MAX_HP)
        @actions = [RestAction.new(0), RangedAttackAction.new, MeleeAttackAction.new, RescueAction.new, PivotAction.new, WalkAction.new] # Order inside array indicates priority
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

    def initialize(scanner)
        @scanner = scanner
        @dir_sensors = {}
        DIRS.each {|d| @dir_sensors[d] = DirectionalSensor.new(d, scanner)}
    end

    def scan(warrior)
        @dir_sensors.values.each{|s| s.scan(warrior)}
    end

    def subject_dealt?(params={})
        check_sensors(params) {|s, dist| s.subject_dealt?(dist)}
    end

    def subject?(params={})
        check_sensors(params) {|s, dist| s.subject?(dist)}
    end

    def subject_dirs(dist=nil)
        DIRS.select {|d| @dir_sensors[d].subject?(dist)}
    end

    def tiles(dir)
        @dir_sensors[dir].tiles
    end

    def subject_min_dist(dir)
        t = tiles(dir)
        raise "No subject in given direction" if t.count < 1
        t.min
    end

    private

    def check_sensors(params={})
        dir, dist = params[:dir], params[:dist]
        dir ? yield(@dir_sensors[dir], dist) : @dir_sensors.values.any? {|s| yield(s, dist)}
    end
end

class DirectionalSensor
    attr_reader :tiles

    def initialize(dir, scanner)
        @dir, @scanner = dir, scanner
    end

    def scan(warrior)
        @prev_count = @count || 0
        @prev_tiles = @tiles || []
        @tiles = []
        warrior.look(@dir).each_with_index {|space, index| @tiles << index if @scanner.call(space)}
        @count = @tiles.count
    end

    def subject_dealt?(distance = nil)
        distance ? !@tiles.include?(distance) && @prev_tiles.include?(distance) : @prev_count > @count
    end

    def subject?(distance = nil)
        distance ? @tiles.include?(distance) : @tiles.count > 0
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

    def unobstructed?(params = {})
        dir, dist = params[:dir], params[:dist]
        @sensors.values.none? {|s| s.tiles(dir).any? {|d| d < dist}}
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
