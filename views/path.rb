@paths = {}
class City
  attr_reader :name
  def initialize(name)
    @name = name
    @paths = {}
  end
end

class Road
  attr_reader :origin, :destination, :distance
  def initialize(origin, destination, distance)
    @origin = origin
    @destination = destination
    @distance = distance

  end

  def add_routes
    self.add_to_paths
  end
end

def add_to_paths

end

def shortest_route
end
