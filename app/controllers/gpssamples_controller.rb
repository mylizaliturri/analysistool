class GpssamplesController < ApplicationController
  def create
    uploaded_io = params[:json]
    if (/\.json$/ =~ uploaded_io.original_filename)
      cUser = User.find(params[:user_id])
      cUser.save
      gps = JSON.parse(uploaded_io.read)
      prepath = cUser.name + '_'
      File.open(Rails.root.join('public', 'uploads', prepath + uploaded_io.original_filename), 'w') do |file|
        file.write(uploaded_io.read)
      end
      gps.each do |g|
        gpssample = Gpssample.new
        gpssample.archivo=prepath
        gpssample.latitude = g["latitude"]
        gpssample.longitude = g["longitude"]
        gpssample.time = g["timestamp"]
        gpssample.userid = params[:user_id]
        gpssample.save
      end
      redirect_to user_path(params[:user_id]), notice: 'Archivo cargado exitosamente'
    else
      redirect_to user_path(params[:user_id]), notice: "Hubo un error en la carga del archvio"
    end
  end
end


