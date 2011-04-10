# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110410121730) do

  create_table "albaran_lineas", :force => true do |t|
    t.integer  "cantidad",                                      :default => 1
    t.integer  "descuento",                                     :default => 0
    t.decimal  "precio_compra",   :precision => 8, :scale => 2
    t.decimal  "precio_venta",    :precision => 8, :scale => 2
    t.integer  "producto_id"
    t.integer  "albaran_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nombre_producto"
    t.integer  "iva"
  end

  create_table "albarans", :force => true do |t|
    t.string   "codigo"
    t.date     "fecha"
    t.boolean  "cerrado",      :default => false
    t.integer  "proveedor_id"
    t.integer  "cliente_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campos", :force => true do |t|
    t.string   "nombre"
    t.string   "tipo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clientes", :force => true do |t|
    t.string   "nombre"
    t.integer  "descuento",  :default => 0
    t.string   "email"
    t.string   "cif"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configuracion", :force => true do |t|
    t.string   "nombre_param"
    t.string   "valor_param"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facturas", :force => true do |t|
    t.date     "fecha",                                                       :null => false
    t.string   "codigo",                                                      :null => false
    t.decimal  "importe",    :precision => 8, :scale => 2,                    :null => false
    t.integer  "albaran_id",                                                  :null => false
    t.boolean  "pagado",                                   :default => false
    t.boolean  "metalico",                                 :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "familias", :force => true do |t|
    t.string   "nombre"
    t.integer  "iva_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forma_pagos", :force => true do |t|
    t.string   "nombre"
    t.boolean  "caja",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ivas", :force => true do |t|
    t.string   "nombre"
    t.integer  "valor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pagos", :force => true do |t|
    t.decimal  "importe",       :precision => 8, :scale => 2, :null => false
    t.date     "fecha",                                       :null => false
    t.integer  "factura_id"
    t.integer  "forma_pago_id",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "productos", :force => true do |t|
    t.string   "codigo"
    t.string   "nombre"
    t.string   "autor"
    t.string   "editor"
    t.string   "anno"
    t.string   "descripcion"
    t.string   "url_imagen"
    t.decimal  "precio",      :precision => 8, :scale => 2,                :null => false
    t.integer  "cantidad",                                  :default => 0
    t.integer  "familia_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proveedors", :force => true do |t|
    t.string   "nombre"
    t.string   "direccion"
    t.string   "email"
    t.string   "telefono"
    t.string   "contacto"
    t.integer  "descuento",  :default => 0
    t.string   "cif"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                       :null => false
    t.text     "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
