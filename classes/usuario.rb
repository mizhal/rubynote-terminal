require 'digest/md5'

class Usuario
  require_relative '../aux_/Serializacion.rb'
  require_relative '../aux_/Validacion.rb'
  
  @nombre = String
  @login = String
  @password = String
  
  attr_reader :cuenta, :nombre, :login
  attr_writer :nombre, :login
  
  # validaciones
  include Validacion
  validates :login, :presencia => true, 
    :sin_espacios => true,
    :login => true
  validates :password, :presencia => true,
    :sin_espacios => true,
    :longitud => {minimo:6, maximo:30}
  validates :nombre, :presencia => true
  
  validacion_con :login, :login_unico, "Ya existe un usuario con ese login"
 
  ## Persistencia de datos
  include Serializacion
  
  ## Interface rubynote_data
  def rubynoteKey
    self.login
  end
  
  def self.crear params
    u = new
    u.nombre, u.login, u.password = params[:nombre], params[:login], params[:password]
    return u
  end
  
  def self.autorizar login, password
    usuario = Usuario.busca(login, true)
    if usuario
      return usuario if usuario.autorizarPassword(password) and 
        (usuario.cuenta.activada or usuario.admin?)
    else
      return nil
    end
  end
  
  def autorizarPassword password
    return Digest::MD5.hexdigest(password) == @password
  end
  
  def password= nueva_p
    @password = Digest::MD5.hexdigest(nueva_p)
  end
  
  def admin?
    return false
  end
  
  def login_unico login
    mismo_login = Usuario.busca(login, true) ## busqueda con herencia
    return false if mismo_login
    return true
  end
end

if __FILE__ == $0
  u0 = Usuario.crear "Luis", "lparm", "Collodi"
  
  puts u0.validar("lparm", "Cllodi")
end