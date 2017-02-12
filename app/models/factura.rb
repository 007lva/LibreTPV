# encoding: UTF-8
#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2013 Santiago Ramos <sramos@sitiodistinto.net> 
#
#    Este programa es software libre: usted puede redistribuirlo y/o modificarlo 
#    bajo los términos de la Licencia Pública General GNU publicada 
#    por la Fundación para el Software Libre, ya sea la versión 3 
#    de la Licencia, o (a su elección) cualquier versión posterior.
#
#    Este programa se distribuye con la esperanza de que sea útil, pero 
#    SIN GARANTÍA ALGUNA; ni siquiera la garantía implícita 
#    MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO. 
#    Consulte los detalles de la Licencia Pública General GNU para obtener 
#    una información más detallada. 
#
#    Debería haber recibido una copia de la Licencia Pública General GNU 
#    junto a este programa. 
#    En caso contrario, consulte <http://www.gnu.org/licenses/>.
#################################################################################
#
#++


class Factura < ActiveRecord::Base

  #belongs_to :albaran
  belongs_to :proveedor
  has_many :pagos
  has_many :albaranes

  after_create :generar_numero_factura
  before_destroy :verificar_borrado
  validates_numericality_of :importe, :message => "La factura debe tener un importe."
  validates_presence_of :codigo, :message => "La factura debe tener un código."

  # devuelve el codigo de la factura o el del albaran si no existe
  def codigo_mayusculas
    (self.codigo == "N/A" && self.albaranes.first && self.albaranes.first.codigo != "") ? "(*) " + self.albaranes.first.codigo.upcase : self.codigo.upcase
  end

  # devuelve el importe pendiente de pago
  def pago_pendiente
    pago_pendiente = self.importe
    self.pagos.each { |pago| pago_pendiente -= pago.importe }
    return pago_pendiente
  end

  # devuelve el debe de una factura
  def debe
    if (!self.albaranes.empty? && ( (self.albaranes.first.proveedor_id && self.importe >= 0) || (self.albaranes.first.cliente_id && self.importe < 0))) || (self.proveedor && self.importe >= 0)
      return self.importe.abs
    else
      return nil 
    end
  end

  # devuelve el haber de una factura
  def haber
    if (!self.albaranes.empty? && ( (self.albaranes.first.cliente_id && self.importe >= 0) || (self.albaranes.first.proveedor_id && self.importe <0))) || (self.proveedor && self.importe < 0)
      return self.importe.abs
    else
      return nil 
    end
  end

  # devuelve el concepto de una factura
  def concepto
    unless (self.albaranes.nil?)
      if self.albaranes.first.cliente_id
        concepto = (self.importe>=0?"Venta ":"Devolucion ") + self.albaranes.first.cliente.nombre
      else
        concepto = (self.importe>=0?"Compra ":"Devolucion compra ") + self.albaranes.first.proveedor.nombre
      end
    else
      concepto = (self.importe>0?"Factura ":"Cobro ") + (self.proveedor ? self.proveedor.nombre : "REVISAME!!!")
      #concepto = (importe>0?"Factura ":"Cobro ") + "REVISAME"
    end
    return concepto
  end

  # devuelve la base imponible tenga o no un albaran asociado
  def base_imponible
    # Si hay un iva asociado a la factura completa (aunque sea 0)
    if ( self.valor_iva )
      return self.importe / (1 + (valor_iva.to_f - valor_irpf.to_f)/100 )
    # Si la factura corresponde a un albaran 
    elsif !self.albaranes.empty?
      return self.importe_base ? self.importe_base : self.albaranes.inject(0) { |val,alb| val + alb.base_imponible }
    end
  end

  # modifica la base imponible
  def base_imponible=(valor)
    self.importe_base = valor.to_f
    if ( self.valor_iva )
      self.importe = valor.to_f * (1 + (valor_iva.to_f - valor_irpf.to_f )/100 )
    else
      self.importe=valor.to_f
    end
  end

  # devuelve el irpf
  def irpf
    return self.base_imponible.abs * self.valor_irpf.to_f/100
  end

  # devuelve el iva aplicado
  def iva_aplicado
    if ( self.valor_iva )
      return self.base_imponible.abs * self.valor_iva.to_f/100
    else
      return self.importe - self.base_imponible
    end
  end

  # devuelve el iva aplicado desglosado segun tipos
  def desglose_por_iva
    if ( self.valor_iva )
      return { self.valor_iva.to_s => [self.base_imponible ,self.base_imponible.abs * self.valor_iva.to_f/100, self.importe] }
    else
      total = {}
      self.albaranes.each do |alb|
        alb.desglose_por_iva.each do |key,values| 
          if total[key]
            total[key] = total[key].zip(values).map {|a| a.inject(:+)}
          else
            total[key] = values
          end  
        end
      end
      return total 
    end
  end

  private
    def generar_numero_factura
      if !albaranes.empty? && albaranes.first.cliente_id
        prefijo = Configuracion.valor("PREFIJO FACTURA VENTA")
        numero = Configuracion.numero_nueva_venta
        self.codigo = prefijo + format("%010d", numero.to_s)
        self.save
      end
    end

    def verificar_borrado
      if !self.pagos.empty?
        errors.add( :base , "No se puede borrar la factura: Hay pagos realizados." ) unless self.pagos.empty?
        return false
      end
    end

end
