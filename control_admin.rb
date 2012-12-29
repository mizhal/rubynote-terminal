


class ControlAdmin
  require_relative './ui_admin.rb'
  require_relative './classes/usuario_admin.rb'
  
  def initialize
    @ui = UIAdmin.new
    @tam_pagina = 5
  end
  
  def main
    while true
      opcion = @ui.menu
      case opcion
        when 1
          crearCuentaYUsuario
        when 2
          borrarCuentaYUsuario
        when 3
          cambiarClaveUsuarios
        when 4
          cambiarTipoUsuario
        when 5
          cnt = 0
          @ui.listarUsuariosCabecera 0
          usuarios = UsuarioNormal.iterador {|usuario|
            if (cnt + 1) % @tam_pagina == 0
              continuar = @ui.comandosListaUsuario
              break if !continuar
              @ui.listarUsuariosCabecera((cnt + 1) / @tam_pagina) 
            end
            @ui.mostrarDatosUsuario usuario, cnt
            cnt +=1
          }
          @ui.listarUsuariosFin
        when 6
          cambiarClaveAdmin
        when 7
          return
        else 
          @ui.opcionErronea
      end
    end
  end
  
  def cambiarClaveAdmin
    admin = UsuarioAdmin.busca 'admin'
    nueva_clave = @ui.cambiarClaveAdmin admin
    if nueva_clave
      admin.password = nueva_clave 
      admin.guarda
      @ui.mensajeConIntro "Se ha modificado la clave de administrador"
    else
      @ui.mensajeConIntro "No se ha modificado la clave de administrador"
    end
  end
end