#!/usr/bin/env  ruby
# encoding: utf-8

# Clase con la capacidad para almacenar y recuperar los objetos
# del modelo

require 'json'

class Archivo

  private
  def initialize
    @instancias = {}
    self.inicializaArchivo
  end
  
  @@singleton = nil
  
  public
  def self.instancia
    @@singleton = Archivo.new if @@singleton == nil
    return @@singleton
  end
  
  def cargaObjeto nombre_clase, id
    coleccion = @instancias[nombre_clase]
    if coleccion
      objeto = coleccion[id]
      if objeto
        return objeto
      else
        raise Exception.new "Solicitada instancia de objeto inexistente"        
      end
    else
      raise Exception.new "Solicitada instancia de objeto inexistente"
    end
  end
  
  def inicializaArchivo
    "tags notas libretas cuentas usuarios".split().each { |fname |
      if !File.exists?("./db/#{fname}.json")
        File.open("./db/#{fname}.json", "w") {|f| f.write(JSON.dump( {} ) ) } 
      end
    }
  end
  
  def guarda
    @instancias.each{ |tipo, instancias| 
      File.open("./db/#{tipo.downcase}s.json", "w") { |f| f.write(JSON.dump(instancias)) }
    }
  end
  
  def carga
    File.open("./db/tags.json") { |f| self.registraEnBloque(JSON.parse(f.read)) } rescue puts e
    File.open("./db/notas.json") { |f| self.registraEnBloque(JSON.parse(f.read)) }  rescue nil 
    File.open("./db/libretas.json") { |f| self.registraEnBloque(JSON.parse(f.read)) } rescue nil
    File.open("./db/cuentas.json") { |f| self.registraEnBloque(JSON.parse(f.read)) } rescue nil   
    File.open("./db/usuarios.json") { |f| self.registraEnBloque(JSON.parse(f.read)) } rescue nil
  end
  
  def limpia
    @instancias = {}
  end
  
  def registraEnBloque hash
    if hash.length > 0
      @instancias[hash.first[1].class.name] = hash
    end
  end
  
  def registra objeto
    @instancias[objeto.class.to_s] ||= {}
    @instancias[objeto.class.to_s][objeto.rubynoteKey] = objeto
  end
  
  def elimina objeto
    @instancias[objeto.class.to_s] ||= {}
    @instancias[objeto.class.to_s].delete objeto.rubynoteKey    
  end
  
end

if __FILE__ == $0
  require './nota.rb'
  
  n1 = Nota.new
  n1.titulo = "Codice: Archivo"
  n1.escribe """El archivo contiene todos los objetos del sistema
  Tambien contiene las funciones para guardar y leer de disco toda la informacion
  """
  
  n2 = Nota.new
  n2.titulo = "Segunda nota"
  n2.escribe "Hola, segunda nota\n... sneak"
  
  t1 = Tag.new
  t1.nombre = ":codice" 
  
  
  
  n1.tags << t1

  Archivo.instancia().carga  
  Archivo.instancia().registra n1
  Archivo.instancia().registra t1
  Archivo.instancia().guarda
  Archivo.instancia().limpia
  
  Archivo.instancia().carga
  
  puts Archivo.instancia().cargaObjeto('Nota', n1.rubynoteKey).tags
  
end
