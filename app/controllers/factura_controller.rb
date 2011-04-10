class FacturaController < ApplicationController
  # Incluimos esto para un trucate en los tickets
  include ActionView::Helpers::TextHelper

  # Hace una busqueda de "factura" para listado 
  before_filter :obtiene_facturas, :only => [ :listado, :aceptar_cobro ]

  def index
    flash[:mensaje] = "Listado de Facturas de Proveedores" if params[:seccion] == "productos"
    flash[:mensaje] = "Listado de Facturas de Clientes" if params[:seccion] == "caja"
    redirect_to :action => :listado
  end

  def listado
  end

  def editar
    @factura = Factura.find(params[:id])
    @albaran = @factura.albaran
    if params[:seccion] != "productos"
      @clientes = Cliente.all
    end
    render :partial => "formulario", :locals => { :proveedor => (@albaran.proveedor.nombre if @albaran.proveedor_id) }
  end

  def modificar
    factura = Factura.find(params[:id])
    if params[:seccion] != "productos"
      albaran = factura.albaran
      albaran.update_attributes params[:albaran]
    end
    factura.update_attributes params[:factura]
    flash[:error] = factura
    redirect_to :action => :listado
  end

  def aceptar_albaran_proveedor
    factura = Factura.new
    factura.fecha = Time.now
    factura.albaran_id = params[:albaran_id]
    factura.codigo = "N/A"
    factura.importe = params[:importe].to_f
    factura.save
    redirect_to :controller => :albarans, :action => :aceptar_albaran, :id => params[:albaran_id]
  end

  def borrar 
    factura = Factura.find(params[:id])
    albaran = factura.albaran
    # Primero elimina los productos relacionados del stock
    lineas = albaran.albaran_lineas
    if params[:seccion] == "productos"
      multiplicador = -1
    else
      multiplicador = 1
    end
    if factura.destroy
      lineas.each do |linea|
        producto=linea.producto
        producto.cantidad += (linea.cantidad * multiplicador)
        producto.save
      end
      # Cambia el estado del albaran a abierto
      albaran.cerrado = false
      albaran.save
      # Elimina la factura
    end
    flash[:error] = factura 
    redirect_to :action => :listado
  end

  def cobrar_albaran
    @factura = Factura.new
    @formasdepago = FormaPago.all
    @importe = params[:importe]
    render :partial => "cobrar_albaran", :albaran_id => params[:albaran_id]
  end

  def aceptar_cobro
    factura = Factura.new
    factura.pagado = true
    factura.codigo = codigo_factura_venta
    factura.update_attributes params[:factura]
    flash[:error] = factura
    pago = Pago.new
    pago.importe = factura.importe
    pago.factura = factura
    pago.fecha = factura.fecha
    pago.forma_pago_id = params[:forma_pago][:id]
    pago.save
    imprime_ticket factura.albaran_id, FormaPago.find_by_id(params[:forma_pago][:id]).nombre
    redirect_to :controller => :albarans, :action => :aceptar_albaran, :id => factura.albaran_id, :forma_pago => params[:forma_pago], :importe => params[:importe], :recibido => params[:recibido]
  end

  def calcula_cambio
    devolver = params[:recibido].to_f - params[:importe].to_f
    render :inline => devolver>=0 ? 'A Devolver<br/>' + devolver.to_s + ' €' : '&nbsp;'
  end

private

  def obtiene_facturas 
    case params[:seccion]
      when "caja"
        condicion = "cliente_id"
      when "productos"
        condicion = "proveedor_id"
      when "trueke"
        condicion = "cliente_id"
    end
    @facturas = Factura.paginate :page => params[:page], :per_page => Configuracion.valor('PAGINADO'), :order => 'facturas.fecha DESC, facturas.codigo DESC', :include => "albaran", :conditions => [ 'albarans.' + condicion + ' IS NOT NULL' ]
  end

  def codigo_factura_venta
    codigo = 0 
    prefijo = Configuracion.valor("PREFIJO FACTURA VENTA")
    @facturas.each do |factura|
      nuevo_codigo = /^#{prefijo}([0-9]+)$/.match(factura.codigo)
      codigo = nuevo_codigo[1].to_i if nuevo_codigo && nuevo_codigo[1] && nuevo_codigo[1].to_i > codigo
    end 
    return prefijo + format("%010d", (codigo+1).to_s)
  end

  def imprime_ticket albaran_id, formadepago
    albaran = Albaran.find_by_id albaran_id
    lineas = albaran.albaran_lineas
    precio_total = 0
    subtotal = 0
    iva_total={}

    nombre_corto = "| " + Configuracion.valor('NOMBRE CORTO EMPRESA') + " |"
    pre_size = (46 - nombre_corto.length.to_i) / 2
    cadena  = " " * pre_size + "-" * nombre_corto.length.to_i + "\n"
    cadena += " " * pre_size + nombre_corto + "\n"
    cadena += " " * pre_size + "-" * nombre_corto.length.to_i + "\n\n"
    cadena += " " + Configuracion.valor('NOMBRE LARGO EMPRESA') + "\n"
    cadena += " C.I.F. " + Configuracion.valor('CIF') + "\n"
    cadena += " " + Configuracion.valor('DIRECCION') + "\n\n" 
    cadena += " Cliente: " + albaran.cliente.nombre + "\n"
    cadena += " Fecha: " + Time.now.strftime("%d-%m-%Y  %H:%M") + "\n"
    cadena += " Ticket: " + albaran.factura.codigo + "\n"
    cadena += " Forma de Pago: " + formadepago + "\n\n"
    cadena += "--------------------------------------------------\n\n"
    cadena += format "Cnt.  %-31s Dto.   Imp.\n\n", "Descripcion"
    lineas.each do |linea|
      cantidad = linea.cantidad
      descuento = linea.descuento
      nombre = truncate(linea.producto.nombre, :length => 31)
      iva = linea.iva
      iva_total[iva] = iva_total.key?(iva) ? iva_total[iva] + (linea.total-linea.subtotal) : linea.total-linea.subtotal 
      subtotal += linea.subtotal 
      precio_total += linea.total 
      cadena += format " %2d  %-32s  %2d  %6s\n", cantidad, nombre, descuento, format("%.2f",linea.total)
    end
    cadena += "\n--------------------------------------------------\n\n"
    cadena += format " %-41s %6s\n", "Subtotal", format("%.2f",subtotal)
    iva_total.each do |tipo,parcial|
      cadena += format " %-41s %6s\n", format("Iva ( %2s%% )",tipo.to_s), format("%.2f",parcial)
    end
    cadena += format "\n %-41s %6s\n\n.", "Total Euros (IVA incluido)", format("%.2f",precio_total.to_s)
    File.open("/tmp/ticket", 'w') {|f| f.write(cadena) }
    system(Configuracion.valor('COMANDO IMPRESION') + " /tmp/ticket")
  end

end
