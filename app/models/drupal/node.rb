# encoding: UTF-8
#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2015 Santiago Ramos <sramos@sitiodistinto.net> 
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


class Drupal::Node < Drupal

  # Eliminamos las materias porque se estan manejando como taxonomias
  #scope :materia, -> { where(type: 'materias') }
  scope :producto, -> { where(type: 'product') }
  scope :autor, -> { where(type: 'autor') }
  scope :editorial, -> { where(type: 'editorial') }
  
  has_one :stock, class_name: 'Drupal::UcProductStock', foreign_key: :nid
  has_one :atributos, class_name: 'Drupal::UcProducts', foreign_key: :nid
  has_one :body, class_name: 'Drupal::FieldDataBody', foreign_key: :entity_id

  validates_presence_of :type, :message => "El tipo no puede estar indefinido."
  validates_presence_of :title, :message => "El nombre no puede estar vacío."

  after_initialize :defaults, :if => :new_record?
  before_save  :valores_modificado
  after_create :ajusta_vid

  # Guarda la fecha de modificacion 
  def valores_modificado
    self.uid = 1
    self.changed = Time.now.to_i
  end

  # Asigna los valores por defecto
  def defaults 
    self.status = 1
    self.comment = 2
    self.promote = 1
    self.sticky = 0
    self.tnid = 0
    self.language = "es"
    self.translate = 0
    self.created = Time.now.to_i
  end

  # Asigna el mismo vid que el nid obtenido
  def ajusta_vid 
    self.update_column(:vid, self.nid)
  end

end
