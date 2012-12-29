class Tag
  require_relative '../aux_/Serializacion.rb'
  
  @nombre = String
  attr_accessor :nombre
  attr_reader :notas, :libretas
  
  ## Persistencia de datos
  include Serializacion
  def cuenta_referencias
    @notas.length + @libretas.length
  end
  
  ## Constructor con parametros
  def self.crear nombre
    n = new
    n.nombre = nombre
    return n
  end
  
  ## Interface rubynote_data
  def rubynoteKey
    self.nombre
  end
  
  def initialize
    @notas = []
    @libretas = []
  end
  
  def asociarNota nota
    @notas << nota unless @notas.include? nota
  end
  
  def desvincularNota nota
    @notas.delete nota
  end
  
  def asociarLibreta libreta
    @libretas << libreta unless @libretas.include? libreta
  end
  
  def desvinculaLibreta libreta
    @libretas.delete libreta
  end
  
  def to_s
    "<Tag #{@nombre}>"
  end
end