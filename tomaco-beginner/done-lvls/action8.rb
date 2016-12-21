
class WalkAction
    def should_exec?(environment, status)
        environment.sensors.none? {|sensor| sensor.subject?({dir: :forward, dist: 0})}
    end

    def exec(warrior)
        warrior.walk!
    end
end

class MeleeAttackAction
    def should_exec?(environment, status)
        enemy_sensor = environment.enemy_sensor
        @dir = nil
        @dir = enemy_sensor.subject_dirs(0)[0] if enemy_sensor.subject?({dist: 0})
        !@dir.nil?
    end

    def exec(warrior)
        warrior.attack! @dir
    end
end

class RangedAttackAction
    def should_exec?(environment, status)
        enemy_sensor = environment.enemy_sensor
        @dir = nil
        possible_dirs = enemy_sensor.subject_dirs
        @dir = possible_dirs.find {|dir| environment.unobstructed? ({dir: dir, dist: enemy_sensor.subject_min_dist(dir)})}
        !@dir.nil? && !enemy_sensor.subject?({dist: 0})
    end

    def exec(warrior)
        warrior.shoot! @dir
    end
end


class RescueAction
    def should_exec?(environment, status)
        captive_sensor = environment.captive_sensor
        @dir = nil
        @dir = captive_sensor.subject_dirs[0] if captive_sensor.subject?({dist: 0})
        !@dir.nil?
    end

    def exec(warrior)
        warrior.rescue! @dir
    end
end

class PivotAction
    def should_exec?(environment, status)
        wall_sensor = environment.wall_sensor
        wall_sensor.subject? ({dir: :forward, dist: 0})
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
