require_relative "archivo.rb"

class ContextoReferencia
  attr_accessor :objeto, :tipo, :indice
  
  def initialize objeto, tipo, indice
    @instancia, @tipo, @indice = objeto, tipo, indice 
  end
  
  def desreferenciar referencia
    referido = Archivo.instancia().cargaObjeto(referencia.class_name, 
      referencia.id)

    case @tipo
      when :array
        @instancia[@indice] = referido
      when :objeto
        @instancia.instance_variable_set("@#{@indice}", referido)
      when :hash
        @instancia[@indice] = referido
    end
  end
end