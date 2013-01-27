#!/usr/bin/env  ruby
# encoding: utf-8

class Libreta
  require_relative 'nota.rb'
  require_relative 'tag.rb'
  require_relative '../aux_/Serializacion.rb'
  require_relative '../aux_/Validacion.rb'
  
  @nombre = String
  @notas = [Nota]
  @tags = {Nota => Tag}
  
  attr_accessor :nombre
  attr_reader :notas, :tags
  
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
  
  ## Interface de Serializacion
  def dependientes
    @notas.each{|n| yield n}
  end
  
  def initialize
    @notas = []
    @tags = {}
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
  
  def vincularNota nota
    unless @notas.include? nota
      @notas << nota 
      nota.tags.each{|t| self.vincularTag(t, nota)}
    end
  end
  
  def desvincularNota nota
    if @notas.include? nota
      @notas.delete nota
      nota.tags.each{|t| self.desvincularTag(t, nota)}      
    end
  end
  
  def vincularTag tag, nota
    unless @tags.has_key? tag
      @tags[tag] = []
      tag.vincularLibreta self
    end 
    @tags[tag] << nota unless @tags[tag].include? nota
  end
  
  def desvincularTag tag, nota
    if @tags.has_key? tag
      @tags[tag].delete nota
      if @tags[tag].empty?
        @tags[tag] = nil
        tag.desvincularLibreta self
      end
    end
  end
  
  def to_s
    "Libreta #{@nombre}"
  end
  
  def buscarPorTexto texto
    re = Regexp.new ".*#{texto}.*", Regexp::IGNORECASE
    @notas.select {|n| n.titulo.match(re) or n.contenido.match(re)}
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