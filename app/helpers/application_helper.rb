# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def cabecera_listado campos
    @campos_listado = campos
    cadena = "<div class='listado'><div class='listadocabecera'>"
    for campo in campos
      cadena += "<div class='listado_campo'>" + campo + "</div>"
    end
    cadena += "<div class='listado_derecha'>"
    cadena += link_to icono('Plus',{:title => "Nuevo"}), {:action => 'new'}
    cadena += "</div></div>"
    return cadena
  end

  def fila_listado objeto
    cadena = ""
    for campo in @campos_listado
      valor=objeto
      campo.split('.').each { |metodo| valor = valor.send(metodo) if valor }
      cadena += "<div class='listado_campo'>" + valor.to_s + '</div>'
    end
    #cadena += "</div>"
    return cadena
  end

  def final_listado objeto
    cadena = "</div>"
    return cadena
  end

  def icono tipo, propiedades={} 
    image_tag("/images/iconos/16/" + tipo + ".png", :border => 0, :title => propiedades[:title] || "", :alt => propiedades[:title], :onmouseover => "this.src='/images/iconos/16/" + tipo + ".png';", :onmouseout => "this.src='/images/iconos/16/" + tipo + ".png';" )
  end

  # dibuja un mensage flash
  def mensaje cadena
    ("<div id = 'mensaje'>" + cadena + "</div>") if flash[:mensaje]
  end

  # dibuja el mensaje de error o de exito
  def mensaje_error objeto, otros={}
    if objeto.class == String
      cadena = '<div id="mensajeerror">'
      cadena << objeto
    else
      if objeto.errors.empty?
        cadena = '<div id="mensajeok">'
        cadena << _("Los datos se han guardado correctamente.") unless otros[:eliminar]
        cadena << _("Se ha eliminado correctamente.") if otros[:eliminar]
      else
        cadena = '<div id="mensajeerror">'
        cadena << _("Se ha producido un error.") + "<br>"
        objeto.errors.each {|a, m| cadena += m + "<br>" }
      end
    end
    return cadena << "</div>"
  end

end
