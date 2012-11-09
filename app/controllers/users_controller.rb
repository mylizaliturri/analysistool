class UsersController < ApplicationController

  def create
    @user = User.new
    @user.name=(params[:user][:name])
    if @user.save
      # redirect the user to index
      redirect_to users_path, notice: 'El usuario fue creado exitosamente'
    else
      # redirect the user to the new method
      render locations_path
    end
  end

  def show
    @user = User.find(params[:id])
    @locations=Location.all();
    @locations_json=@locations.to_json
    #calcular el casco convexo

    temp=Actssample.find_all_by_userid(params[:id]).first()
    if temp.nil?
      @iniacts=0
    else
      @iniacts=temp.time
    end

    coordenadas = Gpssample.find_all_by_userid(params[:id])
    @res=Array.new()
    coordenadas.each {|coord|
      @sitio=Location.new();
      @sitio.latitude=coord.latitude
      @sitio.longitude=coord.longitude
      @locations.each { |loc|
        if inside?(loc, @sitio, 100)
          @res.push(loc)
        end }
    }
    @ruta=coordenadas
    @ruta_json=@ruta.to_json
    @res_json=@res.to_json

    @casco=convex(@ruta)
    @casco_json=@casco.to_json
    if coordenadas.length()>0
      coordenadas.sort_by!{|e| e.nil? ? 0 : e.time }
      @inicio=coordenadas[0].time
      coordenadas.reverse!
      @fin=coordenadas[0].time
    end
  end

  def index
    @users = User.all

    @locations=Location.all();
    @locations_json=@locations.to_json
    #calcular el casco convexo

    @ruta_json=Array.new()
    @caso_json=Array.new()
      coordenadas = Gpssample.all
      @res=Array.new()
      coordenadas.each {|coord|
        @sitio=Location.new();
        @sitio.latitude=coord.latitude
        @sitio.longitude=coord.longitude
        @locations.each { |loc|
          if inside?(loc, @sitio, 100)
            @res.push(loc)
          end }
      }
      @ruta=coordenadas
      @ruta_json=@ruta.to_json
      @res_json=@res.to_json

      @casco=convex(@ruta)
      @casco_json=@casco.to_json
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: 'El usuario fue eliminado.'
  end
end
