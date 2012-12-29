
require_relative "./ui_base.rb"
class UIMain < UIBase
  # dependencias
  require_relative "./classes/usuario_normal.rb"
  
  # atributos
  attr_accessor :flash
    
  # metodos
  def menu
    puts """
Bienvenido a Rubynote
==========================
  #{@flash}
  1. Acceder
  2. Registrarse
  3. Salir    
"""
    return gets.to_i
  end
  
  def adios
    puts "Adios!"
  end
  
  def login
    puts "Introduzca el login de usuario:"
    usuario = gets.to_s.chomp
    puts "login: #{usuario}"
    puts "Escriba su clave"
    clave = gets.to_s.chomp
    puts "<#{usuario}:#{clave}>"
    return [usuario, clave]
  end
  
  def formularioRegistro
    usuario = UsuarioNormal.new
    usuario.login = campo_validado :login,
      "Elija un identificador de login",
      "to_s",
      usuario

    usuario.nombre = campo_validado :nombre, "Escriba su nombre",
      "to_s",
      usuario
      
    usuario.password = campo_validado :password, "Escriba su clave",
      "to_s",
      usuario
      
    puts "Usuario #{usuario.nombre} registrado en el sistema"
    return usuario
  end
end