
class ControlMain
  require_relative "./classes/usuario.rb"
  require_relative "./control_admin.rb"
  require_relative "./control_main.rb"
  require_relative "./ui_main.rb"
  
  def initialize
    @ui = UIMain.new
  end
  
  def main
    while true
      opcion = @ui.menu
      case opcion
        when 1
          login
        when 2
          nuevo_usuario = @ui.formularioRegistro
          nuevo_usuario.guarda if nuevo_usuario
        when 3
          @ui.adios
          return
        else
          @ui.opcionErronea
      end   
    end   
  end
  
  def login
    usuario, clave = @ui.login
    credencial = Usuario.autorizar(usuario, clave)
    if credencial
      puts credencial.nombre
      if credencial.admin?
        require_relative "control_admin.rb"
        ctrl_admin = ControlAdmin.new
        ctrl_admin.main
      else
        require_relative "ui_usuario.rb"
        ui_usuario = UIUsuario.new
        ui_usuario.menu usuario
      end
    else
      @ui.flash = "Usuario desconocido o clave incorrecta"
    end
  end
end