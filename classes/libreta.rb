#!/usr/bin/env  ruby
# encoding: utf-8

class Libreta
  require_relative 'nota.rb'
  require_relative 'tag.rb'
  require_relative '../aux_/Serializacion.rb'
  require_relative '../aux_/Validacion.rb'
  
  @nombre = String
  @notas = [Nota]
  @tags = [Tag]
  
  include Validacion
  validates :nombre, :presencia => true
  
  ## Persistencia de datos
  include Serializacion
  
  def self.crear nombre
    l = new
    l.nombre = nombre
    return l
  end
  
  ## Interface rubynote_data
  def rubynoteKey
    self.nombre
  end
  
  ## Interface RegistroActivo
  def dependent
    @notas.each{|n| yield n}
    @tags.each{|t| yield t}
  end
  
  def initialize
    @notas = []
    @tags = []
  end
  
  def nuevaNota titulo
    nueva = Nota.crear titulo, self
    @notas << nueva
    nueva
  end
  
  def borrarPorTitulo titulo
    @notas.select{|nota| nota.titulo == titulo}
      .each{|nota|
        @notas.delete nota
        nota.destruye
      }
  end
  
  def borrarPorId id
    nota = @notas.select{|x| x.rubynoteKey == id}.first
    @notas.delete note
    nota.destruye
  end
  
  def tags=(*tags_2)
    @tags.each{|tag| tag.desvincularLibreta self}
    @tags = tags
    tags.each{ |tag| tag.asociarLibreta self}
  end
  
  def to_s
    "Libreta #{@nombre}"
  end
  
end

if __FILE__ == $0
  l1 = Libreta.crear "Test"
  
  n1 = l1.nuevaNota "Nota1"
  n1.escribe "Hola"
  l1.defineTag '11'
  n1.tags = "11", "22"
  
  puts n1.tags
  
  require 'json'
  #json1 = JSON.dump l1
  #puts json1
  #o2 = JSON.parse json1
  #puts o2
end