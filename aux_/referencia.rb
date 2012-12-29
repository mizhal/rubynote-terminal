class Referencia
  attr_accessor :class_name, :id, :contexto
  
  def initialize class_name, id
    @class_name, @id = class_name, id
    @contexto = nil
  end
  
  def to_json(*args)
    return { 
      "json_class" => self.class.name,
      "data" => [self.class_name, self.id]
      }.to_json(*args)
  end
  
  def self.json_create(hash)
    nueva_ref = new(*hash["data"])
    Archivo.instancia().registrarReferenciaPendiente nueva_ref
    nueva_ref
  end
  
  def desreferenciar
    @contexto.desreferenciar self
  end
  
  def to_s
    "<Ref #{@contexto} => #{@class_name} #{@id}>"
  end
end