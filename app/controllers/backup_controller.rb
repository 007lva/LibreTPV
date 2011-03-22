# Controlador encargado de backups de BBDD

class BackupController < ApplicationController

  def index
    flash[:mensaje] = _("Desde esta página se pueden realizar backups de la BBDD.")
  end

  def seleccionar
    db_config = Rails::Configuration.new.database_configuration[RAILS_ENV]
    fichero_salida = "#{ENV['RAILS_TMP']}backup.gz"

    system "mysqldump -u #{db_config['username']} --routines -p#{db_config['password']} #{db_config['database']} | gzip -c > #{fichero_salida}"

    if File.exists?(fichero_salida)
      send_file fichero_salida,
        :disposition => 'attachment',
        :type => 'application/gzip',
        :encoding => 'utf8',
        :filename => "tpv_backup_" + Time.new.strftime("%Y%m%d") + ".sql.gz"
      # Elimina los ficheros temporales para no dejarlo sucio (no se puede borrar aqui)
      #File.delete (fichero_salida)
    else
      flash[:error] = _("Error al realizar el backup. Contacte con el administrador del sistema.")
      redirect_to :action => 'index'
    end
  end

end
