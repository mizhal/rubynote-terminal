#!/usr/bin/env  ruby
# encoding: utf-8

# Clase con la capacidad para almacenar y recuperar los objetos
# del modelo

require 'json'

class Archivo
  require_relative './referencia.rb'
  require_relative 'Serializacion.rb'
  
  attr_reader :instancias
  attr_writer :ruta_base

  private
  def initialize
    @instancias = {}
    @refs_pendientes = []
    @ruta_base = nil
    @herencia = {}
  end
  
  @@singleton = nil
  
  public
  def self.instancia
    @@singleton = Archivo.new if @@singleton == nil
    return @@singleton
  end
  
  def cargaObjeto nombre_clase, id, incluye_herencia = false
    if incluye_herencia ## busca tambien en las subclases
      if existeObjeto? nombre_clase, id
        return @instancias[nombre_clase][id]
      else ## busqueda recursiva
        @herencia[nombre_clase].each{ |nombre_subclase|
          # la busqueda que no lance excepcion retornara el objeto
          # elegido
          begin
            o = cargaObjeto(nombre_subclase, id, true) 
            return o
          rescue Exception => e
            nil
          end
        } if @herencia.has_key? nombre_clase
        raise Exception.new "Solicitada instancia de objeto inexistente (#{nombre_clase}[#{id}])"  
      end   
    else
      return @instancias[nombre_clase][id] if existeObjeto? nombre_clase, id
      raise Exception.new "Solicitada instancia de objeto inexistente (#{nombre_clase}[#{id}])"   
    end
  end
  
  def iterador nombre_clase
    @instancias[nombre_clase] ||= {}
    @instancias[nombre_clase].each{|k, v| yield v}
  end
  
  def existeObjeto? nombre_clase, id
    coleccion = @instancias[nombre_clase]
    if coleccion
      objeto = coleccion[id]
      if objeto
        return true    
      end
    end
    return false   
  end
  
  def guarda
    @instancias.each{ |tipo, instancias| 
      File.open("#{@ruta_base}/db/#{tipo.downcase}s.json", "w") { |f| f.write(JSON.dump(instancias)) }
    }
  end
  
  def carga
    Dir.glob("#{@ruta_base}/db/*.json").each { |fname| 
      File.open(fname) {|f| self.registraEnBloque(JSON.parse(f.read)) }
    }
    reconstruirReferencias
    garantizarCuentaAdministrador
  end
  
  def limpia
    @instancias = {}
  end
  
  def registraEnBloque hash
    if hash.length > 0
      class_name = hash.first[1].class.name
      super_class = hash.first[1].class.superclass.name
      @herencia[super_class] ||= []
      @herencia[super_class] << class_name unless 
        @herencia[super_class].include? class_name  
      @instancias[class_name] = hash
    end
  end
  
  def registra objeto
    unless @instancias.has_key? objeto.class.name
      super_class = objeto.class.superclass.name 
      @herencia[super_class] ||= []
      @herencia[super_class] << objeto.class.name unless 
        @herencia[super_class].include? objeto.class.name  
      @instancias[objeto.class.name] = {}
    end 
    @instancias[objeto.class.to_s][objeto.rubynoteKey] = objeto
  end
  
  def elimina objeto
    @instancias[objeto.class.name].delete objeto.rubynoteKey if 
      @instancias.has_key? objeto.class.name
  end
  
  def registrarReferenciaPendiente referencia
    @refs_pendientes << referencia
  end
  
  def reconstruirReferencias
    @refs_pendientes.each{ |r| r.desreferenciar}
    @refs_pendientes = []
  end
  
  def garantizarCuentaAdministrador
    require_relative '../classes/usuario_admin.rb'
    if @instancias.has_key? "UsuarioAdmin" and @instancias["UsuarioAdmin"].has_key? "admin"
      return
    else
      admin = UsuarioAdmin.crear :nombre => 'admin', 
        :login => 'admin',
        :password => '123456'
      admin.guarda
    end
  end
  
end

if __FILE__ == $0
  Archivo.instancia().ruta_base = ".."
  
  n1 = Nota.new
  n1.titulo = "Codice: Archivo"
  n1.escribe """El archivo contiene todos los objetos del sistema
  Tambien contiene las funciones para guardar y leer de disco toda la informacion
  """
  
  n2 = Nota.new
  n2.titulo = "Segunda nota"
  n2.escribe "Hola, segunda nota\n... sneak"
  
  tags = ":codice :anotacin @morrowind".split().map { |tname|
    Tag.crear tname
  } 
  
  n1.tags = tags

  puts "Antes"
  puts n1.tags
  Archivo.instancia().carga  
  n1.guarda
  Archivo.instancia().guarda
  Archivo.instancia().limpia
  
  Archivo.instancia().carga
  
  n1 = Archivo.instancia().cargaObjeto('Nota', n1.rubynoteKey)
  puts "Despues"
  puts n1.tags
  
  n1.destruye
  
  puts "Tags archivo:", Archivo.instancia().instancias['Tag']
  Archivo.instancia().guarda  
end
