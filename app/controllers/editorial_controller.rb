class EditorialController < ApplicationController

  def index
    flash[:mensaje] = 'Listado de Editoriales'
    redirect_to :listado
  end

  def filtrado
    session[('editorial_filtrado_tipo').to_sym] = params[:filtro][:tipo] if params[:filtro]
    session[('editorial_filtrado_valor').to_sym] = ( params[:filtro] && params[:filtro][:valor] != '' ) ? params[:filtro][:valor] : nil
    session[('editorial_filtrado_condicion').to_sym] = params[:filtro] ? params[:filtro][:condicion] : nil
    redirect_to :listado
  end

  def listado
    @campos_filtro = [['Nombre','nombre']]
    paginado = Configuracion.valor('PAGINADO')

    if session[('editorial_filtrado_tipo').to_sym] && session[('editorial_filtrado_valor').to_sym]
      @editoriales = case session[('editorial_filtrado_tipo').to_sym]
      when 'nombre' then
          Editorial.paginate page: params[:page], per_page: paginado,
                order: 'nombre ASC',
                conditions: [ session[('editorial_filtrado_tipo').to_sym] + ' LIKE ?', '%' + session[('editorial_filtrado_valor').to_sym] + "%" ]
        end
    else
      @editoriales = Editorial.paginate page: params[:page], per_page: paginado, order: 'nombre'
    end
  end

  def editar
    @editorial = Editorial.find(params[:id]) || Editorial.new
    render partial: 'formulario'
  end

  def modificar
    @editorial = Editorial.find(params[:id]) || Editorial.new
    if @editorial.id && params[:renombra_editorial] == '1'
      @editorial.renombra params[:editorial][:nombre], true
    else
      @editorial.update_attributes params[:editorial]
    end
    flash[:error] = @editorial
    redirect_to :listado
  end

  def borrar
    @editorial = Editorial.find(params[:id])
    @editorial.destroy
    flash[:error] = @editorial.errors.full_messages.join(' ')
    redirect_to :listado
  end
end
