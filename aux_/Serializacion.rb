require 'date'

module Serializacion
  require_relative "archivo.rb"
  require_relative "referencia.rb"
  require_relative "contexto_referencia.rb"
  
  def self.included(base)
    base.extend MetodosDeClase
  end
  
  module MetodosDeClase
    
    def json_create(o)
      nuevo = self.new
      nuevo.from_json(*o["data"])
      return nuevo
    end
    
    def busca rubynote_key, con_herencia = false
      begin
        Archivo.instancia().cargaObjeto(self.name, rubynote_key, con_herencia)
      rescue Exception => e
        return nil
      end
    end
    
    def iterador
      Archivo.instancia().iterador(self.name){|objeto| yield objeto}
    end
    
    def todos
      col = []
      iterador {|c| col << c}
      return col
    end
  end
  
  
  def guarda
    self.dependientes { |dependientes| dependientes.guarda }
    Archivo.instancia().registra self
  end
  
  def destruye
    antes_de_destruir()
    unless self.cuenta_referencias > 0
      self.dependientes { |dependientes| dependientes.destruye }
      Archivo.instancia().elimina self
      
    end 
  end
  
  ## para implementar en las clases que incorporen el mixin
  ## simplemente debe crear un generador que enumere los
  ## objetos que "componen" el objeto asociado al metodo
  ## son los que tipicamente se borran al borrar el objeto
  ## o se guardan cuando este se guarda
  def dependientes
    nil
  end
  
  def cuenta_referencias
    0
  end
  
  def antes_de_destruir
    #callback para sobreescribir
  end
  
  def to_json *args
    { "json_class"   => self.class.name,
      "data"         => Hash[ 
                          instance_variables.map { |v| 
                            key = v .slice(1..-1)
                            object = self.instance_variable_get(v) 
                            [key, sustituirReferenciasYTiempo(object)]
                          }
                        ]
    }.to_json(*args)
  end
  
  def from_json *hash
    hash.each{|k,v| 
      vincularReferencias(self, k, v) 
      self.instance_variable_set("@#{k}",v)
    }
  end
  
  def sustituirReferenciasYTiempo  object
    if object.respond_to? "rubynoteKey"
      Referencia.new object.class.to_s, object.rubynoteKey
    elsif object.class == Array
      object.map{|x| sustituirReferenciasYTiempo(x)}
    elsif object.class == Hash
      Hash[object.map{|k,v| [k, sustituirReferenciasYTiempo(v)]}]
    elsif object.class == DateTime
      Tiempo.new object.rfc3339
    else
      object
    end
  end

  def vincularReferencias huesped, clave, objeto, tipo = :objeto
    if objeto.class == Referencia
      objeto.contexto = ContextoReferencia.new huesped, tipo, clave
    elsif objeto.class == Array
      objeto.each_with_index{ |x, index| 
        vincularReferencias objeto, index, x, :array
      }
    elsif objeto.class == Hash
      objeto.each{|k, v|
        vincularReferencias objeto, k, v, :hash
      }
    end
  end
  
  def nombreColeccion
    self.class.name.downcase
  end
  
  class Tiempo
    def initialize rfc3339
      @string = rfc3339
    end
    
    def to_json(*args)
        {"json_class" => self.class.name,
        "data" => @string
        }.to_json(*args)
    end
    
    def self.json_create(hash)
      DateTime.rfc3339(hash["data"])
    end   
  end
end