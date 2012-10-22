class LocationsController < ApplicationController
  def index
    # get all locations in the table locations
    @locations = Location.all
  end

  def new
    # default: render ’new’ template (\app\views\locations\new.html.haml)
  end

  def create
    # create a new instance variable called @location that holds a Location object built from the data the user submitted
    @location = Location.new(params[:location])

    # if the object saves correctly to the database
    if @location.save
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully created.'
    else
      # redirect the user to the new method
      render action: 'new'
    end
  end

  def edit
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])
  end

  def update
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # if the object saves correctly to the database
    if @location.update_attributes(params[:location])
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully updated.'
    else
      # redirect the user to the edit method
      render action: 'edit'
    end
  end

  def destroy
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # delete the location object and any child objects associated with it
    @location.destroy

    # redirect the user to index
    redirect_to locations_path, notice: 'Location was successfully deleted.'
  end

  def destroy_all
    # delete all location objects and any child objects associated with them
    Location.destroy_all

    # redirect the user to index
    redirect_to locations_path, notice: 'All locations were successfully deleted.'
  end

  def show
    # default: render ’show’ template (\app\views\locations\show.html.haml)
    @location = Location.find(params[:id])
  end

  def buscar

  end

  def resultados
    @locations=Location.all
    @res=Array.new()

    if params[:sitio] #búsqueda por coordenadas
      @sitio=Location.new(params[:sitio])
      #aqui invoco el método de la tarea 1
      @locations.each { |loc|
        if inside?(loc, @sitio, 100)
          @res.push(loc)
        end }
    end
    if request.post?
        archivo=params[:json]
        @parametros=params
        nombre=archivo
        directorio="tmp/public/tmp"
        @path=File.join(directorio, nombre)

        #File.open(@path,"wb+") do |f|
          #f.write(archivo.read)
        #end

        f = File.read(@path)
        coordenadas = JSON.parse(f)

        coordenadas.each {|coord|
          @sitio=Location.new(coord)
          @locations.each { |loc|
            if inside?(loc, @sitio, 100)
              @res.push(loc)
            end }
        }
    end
  end


  def convexo
    @locations=Location.all
    #calcular el casco convexo
    @casco=convex(@locations)
    #calcular el perimetro del casco convexo
    @distancia=perimetro(@casco)
    #buscar el sitio mas lejano a home
    @home=Location.find_all_by_name('Home')
    @lejano=lejano(@casco,@home)
  end



# @param [Location] lista
  def perimetro(lista)
    #se requieren al menos tres puntos para definir un perimetro
    if lista.length>=3
      i=0
      distancia=0
      while i<lista.length-1
        distancia=distancia+distance(lista[i],lista[i+1])
        i=i+1
      end
      distancia+distance(lista[i],lista[0])
    else
      0
    end
  end

# @param [Location] lista
# @param [Location] home
  def lejano(lista, home)
    #buscar home en las ubicaciones
    if !home.blank?
      #buscar la distancia mas grande entre home y alguno de los puntos y guardarla
      lista.sort_by! {|e| distance(e,home[0])}
      lista.reverse!
      lista[0].name
    else
      "No hay ubicación home"
    end
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



end
