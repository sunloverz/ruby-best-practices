# Another way to hone in on what a class is actually doing is to attempt to describe it
# in one sentence. Remember that a class should do the smallest possible useful thing.
# That thing ought to be simple to describe. If the simplest description you can devise
# uses the word “and,” the class likely has more than one responsibility. If it uses the word
# “or,” then the class has more than one responsibility and they aren’t even very related.

class Gear
  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def ratio
    @chainring / @cog.to_f
  end
end

######################################

# Hide instance variables

class Gear
  attr_reader :chainring, :cog

  def initialize(chainring, cog)
    @chainring = chainring
    @cog       = cog
  end

  def ratio
    chainring / cog.to_f
  end
end


######################################

class ObscuringReferences
  attr_reader :data
  def initialize(data)
    @data = data
  end

  def diameters
    # 0 is rim, 1 is tire
    data.collect {|cell|
      cell[0] + (cell[1] * 2)}
  end
  # ... many other methods that index into the array
end

# rim and tire sizes (now in milimeters!) in a 2d array
@data = [[622, 20], [622, 23], [559, 30], [559, 40]]

######################################

class RevealingReferences
  attr_reader :wheels

  def initialize(data)
    @wheels = wheelify(data)
  end

  # This method clearly has two responsibilities: it iterates over the wheels and it calculates
  # the diameter of each wheel.
  def diameters
    wheels.map {|wheel| wheel.rim + wheel.tire * 2}
  end

  Wheel = Struct.new(:rim, :tire)
  def wheelify(data)
    data.map {|cell| Wheel.new(cell[0], cell[1])}
  end
end

######################################
# Extract extra responsibilites from methods
#
# Methods, like classes, should have a single responsibility. All of the same reasons
# apply; having just one responsibility makes them easy to change and easy to reuse. All
# the same design techniques work; ask them questions about what they do and try to
# describe their responsibilities in a single sentence.

class RevealingReferences
  attr_reader :wheels

  def initialize(data)
    @wheels = wheelify(data)
  end

  def diameters
    wheels.map {|wheel| diameter(wheel)}
  end

  def diameter(wheel)
    wheel.rim + wheel.tire * 2
  end

  Wheel = Struct.new(:rim, :tire)
  def wheelify(data)
    data.map {|cell| Wheel.new(cell[0], cell[1])}
  end
end

######################################

class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, rim, tire)
    @chainring = chainring
    @cog       = cog
    @wheel     = Wheel.new(rim, tire)
  end

  def ratio
    chainring / cog.to_f
  end

  def gear_inches
    ratio * wheel.diameter
  end

  Wheel = Struct.new(:rim, :tire) do
    def diameter
      rim + (tire * 2)
    end
  end
end

######################################

class Gear
  attr_reader :chainring, :cog, :wheel
  def initialize(chainring, cog, wheel = nil)
    @chainring = chainring
    @cog       = cog
    @wheel     = wheel
  end

  def ratio
    chainring / cog.to_f
  end

  def gear_inches
    ratio * wheel.diameter
  end
end

class Wheel
  attr_reader :rim, :tire

  def initialize(rim, tire)
    @rim = rim
    @tire = tire
  end

  def diameter
    rim + tire * 2
  end

  def circumference
    diameter * Math::PI
  end
end

@wheel = Wheel.new(26, 1.5)
puts @wheel.circumference
# -> 91.106186954104

puts Gear.new(52, 11, @wheel).gear_inches
# -> 137.090909090909

puts Gear.new(52, 11).ratio
# -> 4.72727272727273
