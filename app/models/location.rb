class Location < ActiveRecord::Base
  # Set attributes as accessible for mass-assignment
  attr_accessible :latitude, :longitude, :name, :description, :timestamp, :user

end

#implementación del método de haversine para calcular la distancia entre dos coordenadas
def distance(l1,l2)
  #equivalencia de kilometros a radianes
  km = 6376
  #cambio a radianes
  lat1=l1.latitude*Math::PI/180
  lat2=l2.latitude*Math::PI/180
  lon1=l1.longitude*Math::PI/180
  lon2=l2.longitude*Math::PI/180
  dlon = lon2 - lon1
  dlat = lat2 - lat1
  #aplicar formula de haversine
  a = (Math.sin(dlat/2))**2 + Math.cos(lat1) * Math.cos(lat2) * (Math.sin(dlon/2))**2
  c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
  km * c*1000
end

#implementación del método para verificar sí una coordenada esta dentro de otra en un radio r
def inside?(l1,l2,r)
  distance(l1,l2)<r
end

#implementación del método para checar en que ubicación dentro de las conocidas en el arreglo se encuentra (en un radio r)
def where?(l1,locations,r)

  locations.each do |l|
    if distance(l1, l)<r
      return l.name
    end
  end
  false
end

# after graham & andrew
# @param [Object] points
def convex(points)
  lop = points.sort_by { |p| p.latitude }
  left = lop.shift
  right = lop.pop
  lower, upper = [left], [left]
  lower_hull, upper_hull = [], []
  det_func = determinant_function(left, right)
  until lop.empty?
    p = lop.shift
    ( det_func.call(p) < 0 ? lower : upper ) << p
  end
  lower << right
  until lower.empty?
    lower_hull << lower.shift
    while (lower_hull.size >= 3) &&
        !convex?(lower_hull.last(3), true)
      last = lower_hull.pop
      lower_hull.pop
      lower_hull << last
    end
  end
  upper << right
  until upper.empty?
    upper_hull << upper.shift
    while (upper_hull.size >= 3) &&
        !convex?(upper_hull.last(3), false)
      last = upper_hull.pop
      upper_hull.pop
      upper_hull << last
    end
  end
  upper_hull.shift
  upper_hull.pop
  lower_hull + upper_hull.reverse
end

def determinant_function(p0, p1)
  proc { |p| ((p0.latitude-p1.latitude)*(p.longitude-p1.longitude))-((p.latitude-p1.latitude)*(p0.longitude-p1.longitude)) }
end

def convex?(list_of_three, lower)
  p0, p1, p2 = list_of_three
  (determinant_function(p0, p2).call(p1) > 0) ^ lower
end
