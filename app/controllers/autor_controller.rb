class AutorController < ApplicationController

  def index
    flash[:mensaje] = 'Listado de Autores'
    redirect_to :listado
  end

  def filtrado
    session[('autor_filtrado_tipo').to_sym] = params[:filtro][:tipo] if params[:filtro]
    session[('autor_filtrado_valor').to_sym] = ( params[:filtro] && params[:filtro][:valor] != '' ) ? params[:filtro][:valor] : nil
    session[('autor_filtrado_condicion').to_sym] = params[:filtro] ? params[:filtro][:condicion] : nil
    redirect_to :listado
  end

  # Obtiene el listado de autores
  def listado
    @campos_filtro = [['Nombre','nombre']]
    paginado = Configuracion.valor('PAGINADO')

    if session[('autor_filtrado_tipo').to_sym] && session[('autor_filtrado_valor').to_sym]
      @autores = case session[('autor_filtrado_tipo').to_sym]
      when 'nombre' then
          Autor.paginate page: params[:page], per_page: paginado,
                order: 'nombre ASC',
                conditions: [ session[('autor_filtrado_tipo').to_sym] + ' LIKE ?', '%' + session[('autor_filtrado_valor').to_sym] + '%' ]
        end
    else
      @autores = Autor.paginate page: params[:page], per_page: paginado, order: 'nombre'
    end
  end

  # Prepara y presenta el formulario de edicion de un autor
  def editar
    @autor = Autor.find(params[:id]) || Autor.new
    render partial: 'formulario'
  end

  # Actualiza o crea la informacion de un autor
  def modificar
    @autor = Autor.find(params[:id]) || Autor.new
    if @autor.id && params[:renombra_autor] == '1'
      @autor.renombra params[:autor][:nombre], true
    else
      @autor.update_attributes params[:autor]
    end
    flash[:error] = @autor
    redirect_to :listado, page: params[:page]
  end

  # Elimina la informacion de un autor
  def borrar
    @autor = Autor.find(params[:id])
    @autor.destroy
    flash[:error] = @autor.errors.full_messages.join(' ')
    redirect_to :listado, page: params[:page]
  end

  # Sublistado de libros relacionados
  def listado_productos
    autor = Autor.find(params[:id])
    @productos = autor.producto.order('nombre')
    render :update do |page|
      page.replace_html params[:update], partial: 'productos'
    end
  end
end
