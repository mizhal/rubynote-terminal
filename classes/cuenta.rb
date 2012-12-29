module TipoCuenta
  NORMAL = 1
  PREMIUM = 2
end

class Cuenta
  require_relative 'libreta.rb'
  require_relative 'usuario.rb'
  require_relative '../aux_/Serializacion.rb'  
  
  @libretas = {String: Libreta}
  @tipo = TipoCuenta
  @activada = false 
  @usuario = Usuario
  
  attr_accessor :activada
  
  ## Persistencia de datos
  include Serializacion
  
  ## Interface rubynote_data
  def rubynoteKey
    @usuario.login
  end

  def self.crear usuario
    c = new usuario
    return c
  end  
  
  def initialize usuario = nil
    @tipo = TipoCuenta::NORMAL
    @libretas = []
    @usuario = usuario
    @activada = false
  end
  
  def nuevaLibreta nombre
    if @libretas.has_key? nombre
      raise Exception.new("Ya existe una libreta con el mismo nombre")
    end
    nueva = Libreta.crear(nombre)
    @libretas[nombre] = nueva
    nueva
  end
  
  def libreta nombre
    @libretas[nombre]
  end
  
  def existeLibreta? nombre
    @libretas.has_key? nombre
  end
  
  def esPremium?
    @tipo == TipoCuenta::PREMIUM
  end
  
  def cambiaTipo
    if self.esPremium?
      @tipo == TipoCuenta::NORMAL
    else
      @tipo == TipoCuenta::PREMIUM
    end
  end

  
end