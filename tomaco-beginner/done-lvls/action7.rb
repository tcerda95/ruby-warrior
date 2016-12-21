
class WalkAction
    def should_exec?(environment, status)
        !environment.sensors.any? {|sensor| sensor.subject_dir? :forward}
    end

    def exec(warrior)
        warrior.walk!
    end
end

class AttackAction
    def should_exec?(environment, status)
        enemy_sensor = environment.enemy_sensor
        @dir = nil
        @dir = enemy_sensor.dirs[0] if enemy_sensor.subject_nearby?
        !@dir.nil?
    end

    def exec(warrior)
        warrior.attack! @dir
    end
end

class RescueAction
    def should_exec?(environment, status)
        captive_sensor = environment.captive_sensor
        @dir = nil
        @dir = captive_sensor.dirs[0] if captive_sensor.subject_nearby?
        !@dir.nil?
    end

    def exec(warrior)
        warrior.rescue! @dir
    end
end

class PivotAction
    def should_exec?(environment, status)
        wall_sensor = environment.wall_sensor
        wall_sensor.subject_dir? :forward
    end

    def exec(warrior)
        warrior.pivot!
    end
end

class EnemyDefeatedAction
    def should_exec?(environment, status)
        @enemy_count = environment.enemies
        environment.enemy_sensor.subject_dealt?
    end

    def exec(warrior)
        @enemy_count > 0 ? warrior.walk!(:backward) : warrior.walk!
    end
end

class RestAction
    def initialize(min_health)
        @min_health = min_health
    end

    def should_exec?(environment, status)
        status.health < @min_health && !status.took_dmg? && environment.enemies > 0
    end

    def exec(warrior)
        warrior.rest!
    end
end
