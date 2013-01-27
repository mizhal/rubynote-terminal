module Validacion

  def self.included(base)
    base.extend MetodosDeClase
    @validaciones = {}
  end
  
  class ExcepcionValidacion < Exception
  end  
  
  ################
  ################
  class ValidadorGenerico
    ## implementa validaciones genericas para usar en toda la aplicacion
    def presencia objeto, params = {}
      raise ExcepcionValidacion.new "no puede estar vacio" unless objeto != nil || 
        objeto.to_s.length > 0 || 
        objeto.to_s =~ /^\s+$/
    end
    
    def sin_espacios texto, params = {}
      raise ExcepcionValidacion.new "no puede tener espacios" unless texto =~ /^[^\s]+$/
    end
    
    def longitud texto, params = {}
      if  params.has_key? :maximo
        unless texto.length <= params[:maximo] 
          raise ExcepcionValidacion.new "es demasiado largo (max #{params[:maximo]} caracteres)"  
        end
      end
      if  params.has_key? :minimo  
        unless texto.length >= params[:minimo]
          raise ExcepcionValidacion.new "es demasiado corto (min #{params[:minimo]} caracteres)" 
        end
      end 
    end
    
    def login texto, params = {}
      raise ExcepcionValidacion.new "este texto no puede usarse como login" unless 
        texto =~ /^[a-zA-Z][a-zA-Z0-9\-_.]*$/
    end
  end
  ################
  
  ################
  module MetodosDeClase
    VALIDADOR = ValidadorGenerico.new
    
    ## para definir validaciones estándar/genéricas
    def validates simbolo_campo, condiciones
      @validaciones ||= {}
      @validaciones[simbolo_campo] ||= {}
      condiciones.each{ |predicado, params|
        @validaciones[simbolo_campo][predicado] = lambda { |instancia, valor_campo| 
          VALIDADOR.method(predicado).call(valor_campo, params) 
        }
      }
    end
    
    ## Validacion con funciones propias del programador
    def validacion_con simbolo_campo, nombre_metodo, mensaje
      @validaciones ||= {}
      @validaciones[simbolo_campo] ||= {}
      @validaciones[simbolo_campo][":custom:#{nombre_metodo}"] = lambda { |instancia, valor_campo| 
          unless instancia.method(nombre_metodo).call(valor_campo)
            raise ExcepcionValidacion.new mensaje
          end
      }    
    end
    
    def validaciones
      @validaciones
    end
    
    def inherited(subclase)
      ## Heredar las validaciones del padre
      subclase.instance_variable_set "@validaciones", @validaciones
    end
  end
  
  def valida simbolo_campo, valor
    #validaciones = self.class.instance_variable_get :@validaciones
    self.class.validaciones[simbolo_campo].each{ |tipo, funcion|
      funcion.call(self, valor)
    }
  end
end