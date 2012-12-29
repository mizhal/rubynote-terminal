#!/usr/bin/env  ruby
# encoding: utf-8

require_relative "aux_/archivo.rb"
require_relative "./control_main.rb"

Archivo.instancia().ruta_base = "."
Archivo.instancia().carga
ctrl = ControlMain.new
ctrl.main
Archivo.instancia().guarda
