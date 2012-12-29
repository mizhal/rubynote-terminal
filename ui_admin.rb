# encoding: utf-8

require_relative './ui_base.rb'
class UIAdmin < UIBase
  require_relative './classes/usuario_normal.rb'
  
  def menu
    while true
      puts """
Usuario administrador
=========================================
1. Crear o eliminar usuarios
2. Activar o desactivar cuentas
3. Cambiar clave de usuario
4. Cambiar tipo usuario a premium o viceversa
5. Listado de usuarios
6. Cambiar clave de administrador
7. Salir de sesión
  """
      return gets.chomp.to_i
    end
  end
  
  def crearCuentaYUsuario
    
  end
  
  def borrarCuentaYUsuario
    
  end
  
  def cambiarClaveUsuarios
    
  end
  
  def cambiarTipoUsuario
    
  end
  
  def listarUsuariosCabecera pagina
    puts "Listado de usuarios (pagina #{pagina + 1})"
    puts "==================="
    puts "login - nombre real"
    puts 
  end
  
  def mostrarDatosUsuario usuario, contador
    puts "##{contador + 1}: #{usuario.login} - #{usuario.nombre}"
  end
  
  def comandosListaUsuario
    return preguntaSiNo "¿Desea seguir viendo la lista?"
  end
  
  def listarUsuariosFin
    puts
    puts "pulse intro para continuar"
    gets
  end
  
  def cambiarClaveAdmin usuario_admin
    while true
      puts "Escribe la clave actual"
      actual = gets.to_s.chomp
      break if usuario_admin.validarPassword(actual)
      return unless preguntaSiNo "La clave no coincide. ¿Reintentar?"
    end
    nueva_clave = campo_validado "Escriba la nueva clave",
      "to_s",
      usuario_admin,
      :validacion_password => "El texto introducido no sirve como clave"
      
    
    
  end
end