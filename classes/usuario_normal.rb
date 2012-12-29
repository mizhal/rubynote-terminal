require_relative './usuario.rb'


class UsuarioNormal < Usuario
  require_relative './cuenta.rb'

  @cuenta = Cuenta

  attr_reader :cuenta
  
  def initialize *params
   @cuenta = Cuenta.crear(self)
  end
  
  def dependientes
    yield @cuenta
  end
end
