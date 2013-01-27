#coding: utf-8

require 'test/unit'

class ProbarFormulariosYMenus < Test::Unit::TestCase
  require_relative "../aux_/Interfaz.rb"
  require_relative "../classes/usuario.rb"
  require_relative "../aux_/archivo.rb"
  include Interfaz
  
  ## las clases deben estar definidas para que el archivo pueda des-serializarlas
  require_relative '../classes/cuenta.rb'
  require_relative '../classes/libreta.rb'
  require_relative '../classes/nota.rb'
  require_relative '../classes/tag.rb'
  require_relative '../classes/usuario_admin.rb'
  require_relative '../classes/usuario_normal.rb'  
    
  attr_accessor :valor
  
  def setup
    Archivo.instancia().ruta_base = ".."
    Archivo.instancia().carga
  end
  
  def teardown
    
  end
  
  def test_1
    self.valor = "xxxxi"
    Menu::lanza do |m|
      m.titulo = "Prueba menú"
      m.opcion "primera opcion", method(:primera_opcion)
      m.opcion "segunda opcion", method(:segunda_opcion)
      m.opcion "salir", lambda {|contexto| contexto.salir = true}
    end
    
    datos_usuario = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.titulo = "Prueba formulario"
      f.validador = Usuario.new
      f.campo :login, "introduzca usuario", :String
      f.campo :nombre, "escriba su nombre", :String
      f.campo :password, "escriba la clave", :String
    end
  end
  
  def primera_opcion contexto
    puts "primera opcion #{valor}"
  end
  
  def segunda_opcion contexto
    puts "segunda opcion #{valor}"
  end
end