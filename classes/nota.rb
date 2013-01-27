#!/usr/bin/env  ruby
# encoding: utf-8

class Nota
  require 'date'
  require_relative 'tag.rb'
  require_relative 'libreta.rb'
  require_relative '../aux_/Serializacion.rb'
  
  @titulo = String
  @contenido = String
  @tags = [Tag]
  @creado = DateTime::now
  @modificado = DateTime::now
  @libreta = Libreta
  
  attr_accessor :titulo, :libreta
  attr_reader :contenido, :creado, :modificado, :tags
  
  ## Persistencia de datos
  include Serializacion
  
  ## Constructor con parametros
  def self.crear titulo, libreta
    n = new
    n.titulo = titulo
    n.libreta = libreta
    return n
  end
  
  ## Interface rubynote_data
  def rubynoteKey
    self.creado.rfc3339
  end
  
  ## constructor sin parametros
  def initialize
    @tags = []
    @creado = DateTime::now
    @modificado = DateTime::now
  end
  
  ## sustituye el contenido de la nota
  def escribe contenido
    @contenido = contenido
    @modificado = DateTime::now
  end
  
  ## modificación de tags
  def tags= tags_2
    @tags.each{|tag| tag.desvincularNota self}
    @tags.each{|tag| @libreta.desvincularTag self}
    @tags = tags_2
    tags_2.each{|tag| tag.vincularNota self}
    tags_2.each{|tag| @libreta.vincularTag tag, self}
    @modificado = DateTime::now
  end
  
  def libreta= libreta
    @libreta.desvincularNota(self) if @libreta
    @libreta = libreta
    @libreta.vincularNota self
  end

  ## @overrides Serializacion#antes_de_destruir  
  def antes_de_destruir
    @tags.each{|tag| 
      tag.desvincularNota self
    }    
    @libreta.desvincularNota self if @libreta
  end
  
  ## @overrides Serializacion#dependientes
  def dependientes
    @tags.each{|t| yield t}
  end
end


if __FILE__ == $0
  n1 = Nota.new 
  n1.titulo = "Donde estabas tú cuando el Dragón se rompió"
  
  n1.escribe """Every culture on Tamriel remembers the Dragon Break in some fashion; 
to most it is a spiritual anguish that they cannot account for. Several texts survive this 
timeless period, all (unsurprisingly) conflicting with each other regarding events, people, 
and regions: wars are mentioned in some that never happen in another, the sun changes color 
depending on the witness, and the gods either walk among the mortals or they don't. Even 
the \"one thousand and eight years\", a number (some say arbitrarily) chosen by the Elder 
Council, is an unreliable measure.
"""
  
  n1.tags = ['lore', 'tamriel', '@morrowind', ':book-excerpt'].map{|t| o = Tag.new;o.nombre=t;o}
  
  n1.tags << "meet"
  
  puts n1.creado, n1.tags, n1.titulo
  puts n1.contenido
  
  require 'json'
  puts "____________"
  puts n1.to_json
  jsont = JSON.generate n1
  puts jsont
  
  
  puts 
  puts "=============="
  o = JSON.parse(jsont)
  puts o
  puts ">>>#{o.tags}, time: #{o.creado}"
  
end