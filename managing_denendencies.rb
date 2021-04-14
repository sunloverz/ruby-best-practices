# An object has a dependency when it knows
#
# • The name of another class. Gear expects a class named Wheel to exist.
# • The name of a message that it intends to send to someone other than self .
#   Gear expects a Wheel instance to respond to diameter .
# • The arguments that a message requires. Gear knows that Wheel.new requires a
#   rim and a tire .
# • The order of those arguments. Gear knows the first argument to Wheel.new
#   should be rim, the second, tire.

class Gear
  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog = cog
    @rim = rim
    @tire = tire
  end

  def gear_inches
    ratio * Wheel.new(rim, tire).diameter
  end

  def ratio
    chainring / cog.to_f
  end
end

class Wheel
  attr_reader :rim, :tire
  def initialize(rim, tire)
    @rim = rim
    @tire = tire
  end

  def diameter
    rim + (tire * 2)
  end
end

Gear.new(52, 11, 26, 1.5).gear_inches

######################################

# Inject Dependencies

class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, wheel)
    @chainring = chainring
    @cog = cog
    @heel = wheel
  end

  def gear_inches
    ratio * wheel.diameter
  end

  def ratio
    chainring / cog.to_f
  end
end

# Gear expects a ‘Duck’ that knows ‘diameter’
Gear.new(52, 11, Wheel.new(26, 1.5)).gear_inches

######################################

# Isolate Dependencies

# Isolate Instance Creation
# If you can't inject a Wheel into a Gear, you should
# isolate the create of a new Wheel inside the Gear class.

class Gear
  attr_reader :chainring, :cog, :rim, :tire, :wheel
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @wheel     = Wheel.new(rim, tire)
  end

  def gear_inches
    ratio * wheel.diameter
  end
end

######################################

# The next alternative isolates creation of a new Wheel in its
# own explicitly defined wheel method.

class Gear
  attr_reader :chainring, :cog, :rim, :tire
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
  end

  def gear_inches
    ratio * wheel.diameter
  end

  def wheel
    @wheel ||= Wheel.new(rim, tire)
  end
end

######################################

# Isolate Vulnerable External Messages

def gear_inches
  ratio * diameter
end

def diameter
  wheel.diameter
end

######################################

# Remove Argument-Order Dependencies

class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, wheel)
    @chainring = chainring
    @cog       = cog
    @wheel     = wheel
  end

  def gear_inches
    ratio * diameter
  end

  def diameter
    wheel.diameter
  end
end

Gear.new(
    52,
    11,
    Wheel.new(26, 1.5)).gear_inches

######################################

# Use Hashes for Initialization Arguments

class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(args)
    @chainring = args[:chainring] || 40
    @cog       = args[:cog] || 18
    @wheel     = args[:wheel]
  end
  ...
end

Gear.new(chainring: 52, cog: 11,
         wheel: Wheel.new(26, 1.5)).gear_inches

######################################

# When Gear is part of an external interface

module SomeFramework
  class Gear
    attr_reader :chainring, :cog, :wheel
    def initialize(chainring, cog, wheel)
      @chainring = chainring
      @cog       = cog
      @wheel     = wheel
    end
    # ...
  end
end

# wrap the interface to protect yourself from changes
module GearWrapper
  def self.gear(args)
    SomeFramework::Gear.new(args[:chainring],
                            args[:cog],
                            args[:wheel])
  end
end

# Now you can create a new Gear using an arguments hash.
GearWrapper.gear(
    :chainring => 52,
    :cog       => 11,
    :wheel     => Wheel.new(26, 1.5)).gear_inches


######################################

# Managing Dependency Direction

# Reversing Dependencies

class Gear
  attr_reader :chainring, :cog
  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def gear_inches(diameter)
    ratio * diameter
  end

  def ratio
    chainring / cog.to_f
  end
end

class Wheel
  attr_reader :rim, :tire, :gear
  def initialize(rim, tire, chainring, cog)
    @rim       = rim
    @tire      = tire
    @gear      = Gear.new(chainring, cog)
  end

  def diameter
    rim + (tire * 2)
  end

  def gear_inches
    gear.gear_inches(diameter)
  end
end
