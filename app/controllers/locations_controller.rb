class LocationsController < ApplicationController
  def index
    # get all locations in the table locations
    @locations = Location.all
    @locations_json=@locations.to_json

    #calcular el casco convexo
    @casco=convex(@locations)
    @casco_json=@casco.to_json

    @distancia=perimetro(@casco)
    #buscar el sitio mas lejano a home
    @home=Location.find_all_by_name('Home')
    @lejano=lejano(@casco,@home)
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


    # get all locations in the table locations
    @locations = Location.all
    @locations_json=@locations.to_json

    #calcular el casco convexo
    @casco=convex(@locations)
    @casco_json=@casco.to_json

    if params[:sitio] #búsqueda por coordenadas
      @sitio=Location.new(params[:sitio])
      #aqui invoco el método de la tarea 1
      @locations.each { |loc|
        if inside?(loc, @sitio, 100)
          @res.push(loc)
        end }
    end
    if request.post? and params[:json]

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
        @ruta=coordenadas
    end
    @ruta_json=@ruta.to_json
    @res_json=@res.to_json
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





end
