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
  @tag_index = {String => [Nota]}
  @cuenta = Cuenta
  
  attr_accessor :nombre
  attr_reader :notas, :tags
  attr_accessor :cuenta
  
  include Validacion
  validates :nombre, :presencia => true
  
  ## Persistencia de datos
  include Serializacion
  
  def self.crear nombre, cuenta
    l = new
    l.nombre = nombre
    l.cuenta = cuenta
    return l
  end
  
  ## Interface rubynote_data
  def rubynoteKey
    "#{self.nombre}:#{self.cuenta.rubynoteKey}" 
  end
  
  ## Interface de Serializacion
  def dependientes
    @notas.each{|n| yield n}
  end
  
  def initialize
    @notas = []
    @tags = []
    @tag_index = {}
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
    unless @tag_index.has_key? tag.nombre
      @tag_index[tag.nombre] = []
      @tags << tag
      tag.vincularLibreta self
    end 
    @tag_index[tag.nombre] << nota unless @tag_index[tag.nombre].include? nota
  end
  
  def desvincularTag tag, nota
    if @tag_index.has_key? tag.nombre
      @tag_index[tag.nombre].delete nota
      if @tag_index[tag.nombre].empty?
        @tag_index.delete tag.nombre
        @tags.delete tag
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
  
  def buscaPorNombresDeTags tag_names
    notas = []
    tag_names.each{ |tag_name|
      if @tag_index.has_key? tag_name
        @tag_index[tag_name].each{|nota| notas << nota unless notas.include? nota}
      else
        puts "La tag #{tag_name} no existe en la libreta"
      end
    }
    return notas
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