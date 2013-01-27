#!/usr/bin/env  ruby
# encoding: utf-8

require_relative "aux_/archivo.rb"
require_relative "./ui_main.rb"

## las clases deben estar definidas para que el archivo pueda des-serializarlas
require_relative 'classes/cuenta.rb'
require_relative 'classes/libreta.rb'
require_relative 'classes/nota.rb'
require_relative 'classes/tag.rb'
require_relative 'classes/usuario_admin.rb'
require_relative 'classes/usuario_normal.rb'  

Archivo.instancia().ruta_base = "."
Archivo.instancia().carga
ctrl = UIMain.new
ctrl.main
Archivo.instancia().guarda
