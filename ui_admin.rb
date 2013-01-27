# encoding: utf-8

class UIAdmin
  require_relative 'classes/usuario_normal.rb'
  require_relative "aux_/Interfaz.rb"
  
  include Interfaz
  
  def initialize contexto
    @contexto = contexto
  end
  
  def main
    Menu::lanza do |m| 
      m.titulo = "Usuario administrador"
      m.opcion "Gestión de usuarios (crear, destruir, listar)", method(:gestionUsuarios)
      m.opcion "Cambiar tipo usuario a premium o viceversa", method(:gestionPremium)
      m.opcion "Listado de usuarios", method(:listadoUsuarios)
      m.opcion "Cambiar clave de administrador", method(:cambiarClave)
      #m.opcion "Exportar base de datos", method(:exportarBD)
      #m.opcion "Importar base de datos", method(:importarBD)
      m.opcion "Salir de sesión", lambda {|contexto| contexto.salir = true}
    end
  end
  
  def gestionUsuarios contexto
    Menu::lanza do |m| 
      m.titulo = "Administrador: Gestion de Usuarios"
      m.opcion "Crear nuevo usuario", method(:crearUsuario)
      m.opcion "Eliminar usuario", method(:eliminarUsuario)
      m.opcion "Activar/Desactivar cuenta de usuario", method(:gestionCuentas) 
      m.opcion "Listado de usuarios", method(:listadoUsuarios)
      m.opcion "Volver a menú de administrador", lambda {|contexto| contexto.salir = true}    
    end
  end
  
  def crearUsuario contexto
    datos_usuario = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.titulo = "Nuevo usuario"
      f.validador = UsuarioNormal.new
      f.campo :login, "Elija un identificador de login", :String
      f.campo :nombre, "Escriba su nombre", :String
      f.campo :password, "Escriba su clave", :String
    end
    
    if datos_usuario
      usuario = UsuarioNormal::crear datos_usuario
      usuario.guarda
      puts "Usuario #{usuario.nombre} creado en el sistema"
    end
  end
  
  def eliminarUsuario contexto
    datos_usuario = Formulario::lanza :estilo_validacion => :final do |f|
      f.titulo = "Eliminar usuario"
      f.campo :login, "Escribar el login del usuario a eliminar", :String
      f.validacion = lambda {|hash, contexto|
        raise Exception.new "No se puede eliminar el usuario admin" if hash[:login] == 'admin'
        u = Usuario.busca(hash[:login], true)
        raise Exception.new "El usuario no existe" unless u
      }
    end
    
    if datos_usuario
      u = Usuario.busca(datos_usuario[:login], true)
      Archivo.instancia().elimina u
      puts "Usuario #{u.login} eliminado del sistema"
    end
  end
  
  def listadoUsuarios contexto
    Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = UsuarioNormal.todos
      l.titulo = "Listado de usuarios"
      l.campo :login
      l.campo :nombre
    end
    puts "Fin listado"
    puts
  end
  
  def gestionCuentas contexto
    datos_usuario = Formulario::lanza :estilo_validacion => :final do |f|
      f.titulo = "Gestión de cuentas"
      f.campo :login, "Login del dueño de la cuenta", :String
      f.validacion = lambda { |hash, contexto|
        raise Exception.new "El usuario admin no tiene cuenta" if hash[:login] == 'admin'
        u = Usuario.busca(hash[:login], true)
        raise Exception.new "El usuario no existe" unless u
      }
    end

    u = UsuarioNormal.busca datos_usuario[:login]    
    if u.cuenta.estaActivada?
      puts "El usuario #{u.nombre} tiene la cuenta activada"
    else
      puts "El usuario #{u.nombre} tiene la cuenta desactivada"
    end
      
    if Widget::preguntaSiNo "Quiere modificar el estado de la cuenta"
      if u.cuenta.estaActivada?
        u.cuenta.desactiva 
      else
        u.cuenta.activa
      end
      puts "El estado de la cuenta ha sido modificado"
    else
      puts "No se modifica el estado de cuenta"
    end
  end  
  
  def gestionPremium contexto
    datos_usuario = Formulario::lanza :estilo_validacion => :final do |f|
      f.titulo = "Gestión de usuarios premium"
      f.campo :login, "Login del dueño de la cuenta", :String
      f.validacion = lambda { |hash, contexto|
        raise Exception.new "El usuario admin no tiene tipo de cuenta" if hash[:login] == 'admin'
        u = Usuario.busca(hash[:login], true)
        raise Exception.new "El usuario no existe" unless u
      }
    end
    
    if datos_usuario

      u = UsuarioNormal.busca datos_usuario[:login]    
      if u.cuenta.esPremium?
        puts "El usuario #{u.login} tiene cuenta de tipo premium"
      else
        puts "El usuario #{u.login} tiene una cuenta normal"
      end
        
      if Widget::preguntaSiNo "Quiere modificar el tipo de cuenta"
        u.cuenta.cambiaTipo
        puts "El tipo de cuenta ha cambiado a #{u.cuenta.esPremium? ? 'premium': 'normal'}"
      else
        puts "No se modifica el tipo de cuenta"
      end
      
    end
  end
  
  def cambiarClave contexto
    datos_usuario = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.titulo = "Cambio de clave de administrador"
      f.campo :clave_antigua, "Introduzca la clave actual", :String
      f.valida_campo :clave_antigua, lambda {|datos, contexto|
        admin = UsuarioAdmin.busca "admin"
        contexto["admin"] = admin
        unless admin.autorizarPassword(datos)
          raise Exception.new "La clave es errónea"
        end
      }
      f.campo :clave_nueva, "Escriba la nueva clave", :String
      f.valida_campo :clave_nueva, lambda { |datos, contexto|
        admin = contexto["admin"]
        admin.valida :password, datos
        contexto[:clave_nueva] = datos
      }
      f.campo :clave_nueva_confirmacion, "Confirme la nueva clave", :String
      f.valida_campo :clave_nueva_confirmacion, lambda { |datos, contexto|
        unless contexto[:clave_nueva] == datos
          raise Exception.new "La confirmación no coincide con la clave nueva"
        end
      }
    end
    
    if datos_usuario
      
      admin = UsuarioAdmin.busca "admin"
      admin.password = datos_usuario[:clave_nueva]
      
    end
  end
end