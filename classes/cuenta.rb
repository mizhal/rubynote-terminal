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
  attr_reader :libretas
  
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
    @libretas = [Libreta.crear("Varios", self)]
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
  
  def existeLibreta? nombre
    ! @libretas.select{|x| x.nombre == nombre}.empty?
  end
  
  def esPremium?
    @tipo == TipoCuenta::PREMIUM
  end
  
  def cambiaTipo
    if self.esPremium?
      @tipo = TipoCuenta::NORMAL
    else
      @tipo = TipoCuenta::PREMIUM
    end
  end
  
  def estaActivada?
    @activada
  end
  
  def desactiva
    @activada = false
  end
  
  def activa
    @activada = true
  end
  
  def dependientes
    @libretas.each{|l| yield l}
  end
  
  def buscaLibretasPorNombre nombre
    re = Regexp.new ".*#{nombre}.*", Regexp::IGNORECASE
    @libretas.select{|l| l.nombre.match(re)}
  end
  
end