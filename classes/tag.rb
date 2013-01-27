class Tag
  
  @nombre = String
  attr_accessor :nombre
  attr_reader :notas, :libretas
  
  ## Persistencia de datos
  require_relative '../aux_/Serializacion.rb'
  include Serializacion
  
  def cuenta_referencias
    @libretas.length
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
  
  def vincularLibreta libreta
    @libretas << libreta
  end
  
  def desvincularLibreta libreta
    @libreta.delete libreta
  end
  
  def vincularNota nota
    @notas << nota unless @notas.include? nota
  end
  
  def desvincularNota nota
    @notas.delete nota
  end
  
  def to_s
    "<Tag #{@nombre}>"
  end
end