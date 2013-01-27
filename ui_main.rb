class UIMain
  # dependencias
  require_relative "./classes/usuario_normal.rb"
  require_relative "./aux_/Interfaz.rb"
  
  require_relative "ui_usuario.rb"
  require_relative "ui_admin.rb"
  
  # atributos
  attr_accessor :flash
  
  include Interfaz
  
  def initialize
    @contexto = {}
  end
    
  # metodos
  def main
    Menu::lanza do |m| 
      m.titulo = "Bienvenido a Rubynote"
      m.opcion "Acceder", method(:acceder)
      m.opcion "Registrarse", method(:registrarse)
      m.opcion "Salir", lambda {|contexto| contexto.salir = true}    
    end
  end
  
  def acceder contexto
    datos_usuario = Formulario::lanza :estilo_validacion => :final do |f|
      f.titulo = "Login"
      f.campo :login, "Introduzca el login de usuario:", :String
      f.campo :password, "Escriba su clave", :String
      f.validacion = lambda {|hash_datos, contexto| 
        usuario = Usuario.busca hash_datos[:login], true 
        if usuario
          if usuario.autorizarPassword(hash_datos[:password])
            raise Exception.new "Cuenta desactivada" unless usuario.cuentaActiva?
          else
            raise Exception.new "Clave incorrecta"
          end
        else
          raise Exception.new "Usuario desconocido"
        end
      }
    end
    
    if datos_usuario != nil
      usuario = Usuario.busca(datos_usuario[:login], true)
      @contexto[:usuario_sesion] = usuario
      if usuario.admin?
        ui_admin = UIAdmin.new @contexto
        ui_admin.main
      else
        ui_usuario = UIUsuario.new @contexto
        ui_usuario.main
      end
    else
      return nil
    end
    
  end
  
  def registrarse contexto
    datos_usuario = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.titulo = "Registro de nuevo usuario"
      f.validador = UsuarioNormal.new
      f.campo :login, "Elija un identificador de login", :String
      f.campo :nombre, "Escriba su nombre", :String
      f.campo :password, "Escriba su clave", :String
    end
    
    if datos_usuario
      usuario = UsuarioNormal::crear datos_usuario
      usuario.guarda
      puts "Usuario #{usuario.nombre} registrado en el sistema"
    end
  end
end