class ActssamplesController < ApplicationController
  respond_to :html, :json

  def index
    @actssamples = Actssample.select('count').where(:userid=>params[:user_id])

    @arreglo=Array.new();

    @actssamples.each do |a|
      @arreglo.push(a.count)
    end

    respond_with(@arreglo)
  end

  def create
    uploaded_io = params[:json]
    if (/\.json$/ =~ uploaded_io.original_filename)
      cUser = User.find(params[:user_id])
      cUser.save
      acts = JSON.parse(uploaded_io.read)
      prepath = cUser.name + '_'
      File.open(Rails.root.join('public', 'uploads', prepath + uploaded_io.original_filename), 'w') do |file|
        file.write(uploaded_io.read)
      end
      acts.each do |a|
        actssample = Actssample.new
        actssample.count = a["count"]
        actssample.time  = a["timestamp"]
        actssample.userid = params[:user_id]
        actssample.save
      end
      redirect_to user_path(params[:user_id]), notice: 'Archivo cargado exitosamente'
    else
      redirect_to user_path(params[:user_id]), notice: "Hubo un error en la carga del archvio"
    end
  end
end


