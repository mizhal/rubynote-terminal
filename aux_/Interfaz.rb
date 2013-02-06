#coding: utf-8

module Interfaz
  
  class Widget
    def self.preguntaSiNo(texto)
      while true
        puts "#{texto} (S/n)"
        opcion = gets.chomp
        return true if opcion.empty? ## se acepta por defecto, si no se escribe nada
        if "sn".index(opcion[0].downcase) and opcion.length == 1
          return true if opcion[0].downcase == 's'
          return false 
        end
      end
    end    
    
    def self.introParaContinuar
      puts "pulse intro para continuar"
      gets
    end
  end
  
  class Menu < Widget
    attr_reader :opciones
    attr_accessor :titulo, :contexto, :anfitrion, :salir, :flash
    
    def initialize
      @opciones = []
      @contexto = self ## contexto por omision
    end
    
    def opcion texto, manejador
       @opciones << [texto, manejador]
    end  
    
    def ejecutaOpcion indice, contexto
      manejador = @opciones[indice][1]
      case manejador.class.name
        when 'Symbol'
          return @anfitrion.method(manejador).call(contexto)
        when 'Method'
          return manejador.call(contexto)
        when 'Proc'
          return manejador.call(contexto)      
        else
          raise Exception.new "Este objeto no se puede usar como manejador"
      end
    end
    
    def printFlash
      puts self.flash.call() if self.flash
    end
    
    def ejecuta
      while true
        puts
        puts @titulo
        puts "=" * @titulo.length
        printFlash
        @opciones.each_with_index{ |opcion, indice|
          puts "\t#{indice + 1}. #{opcion[0]}"  
        }
        puts
        puts "Elija una opción:"
        opcion = gets.chomp.to_i
        if opcion > 0 and opcion <= @opciones.length
          ejecutaOpcion(opcion - 1, @contexto)
          return if @contexto.salir
        else
          opcionErronea
        end 
        
      end
            
    end
    
    def opcionErronea()
      puts "opcion desconocida (intro para continuar)"
      gets
    end
    
    
    def self.lanza
      m = Menu.new
      yield m
      m.ejecuta
    end
    
  end
  
  class Formulario < Widget
    attr_reader :campos, :estilo_validacion
    attr_accessor :titulo, :validador, :validacion, :contexto, :mensaje_error
    
    def initialize params
      @campos = []
      @estilo_validacion = params[:estilo_validacion] #puede ser: nil, :cada_campo o :al_final
      @contexto = {}
      @valida_campos = {}
    end
    
    def campo nombre, texto, conversor
      @campos << [nombre, texto, conversor]
    end
    
    def valida_campo nombre, lambda_
      @valida_campos[nombre] = lambda_ 
    end
    
    def ejecuta
      datos = {}
      while true
        if @titulo
          puts @titulo
          puts "-" * @titulo.length
        end
        @campos.each{ |campo|
          if @estilo_validacion == :cada_campo
            while true
              entrada = Formulario::consultaUsuario(campo[1], campo[2])
              return nil if entrada == nil

              begin
                @validador.valida(campo[0], entrada) if @validador
                @valida_campos[campo[0]].call(entrada, contexto) if @valida_campos.has_key? campo[0]
                break
              rescue Exception => e
                puts "Campo #{campo[0]}: #{e}"
                return nil unless Formulario::preguntaSiNo("Desea intentarlo de nuevo")
              end
            end
          elsif @estilo_validacion == :final or @estilo_validacion == nil
            entrada = Formulario::consultaUsuario(campo[1], campo[2])
          else
            raise Exception.new "Estilo de validacion de formulario desconocido"
          end
          datos[campo[0]] = entrada
        }
        if @estilo_validacion == :final
          begin
            self.validacion.call(datos, @contexto)
            return datos
          rescue Exception => e
            puts "#{e}"
            return nil unless Formulario::preguntaSiNo("Desea intentarlo de nuevo")
          end
        else
          return datos
        end
      end
    end
    
    def self.consultaUsuario(texto_pregunta, 
      conversor_tipo_dato, 
      texto_bienvenida = nil, 
      texto_rechazo = "valor incorrecto")
      ## conversor_tipo_dato es uno de los metodos de ruby de conversion: Integer, String, Float
      while true
        puts texto_pregunta
        begin
          dato = Kernel::method(conversor_tipo_dato).call(gets.chomp)
          puts texto_bienvenida if texto_bienvenida
          return dato
        rescue
          puts texto_rechazo
          return nil unless Widget::preguntaSiNo("Desea volver a intentarlo")
        end
      end
    end
    
    def self.lanza params = {}
      f = Formulario.new params
      yield f
      return f.ejecuta
    end
    
  end


  class Listado < Widget
    
    attr_accessor :coleccion, :titulo, :tam_pagina, :intro_al_final
    
    def initialize
      @campos = []
      @intro_al_final = true
    end
    
    def campo nombre
      @campos << nombre
    end
    
    def ejecuta
      cabecera
      if @coleccion.empty?
        puts "No hay nada"
        puts "pulse intro para continuar"
        gets        
        return false
      end
      @coleccion.each_with_index{ |elemento, indice|
        datos = @campos.map { |campo| elemento.method(campo).call }.join(", ")
        puts "#{indice}. #{datos}"
        if indice + 1 < @coleccion.length and ((indice + 1) % @tam_pagina) == 0
          return unless Widget::preguntaSiNo "Desea continuar con el listado?"
          cabecera
        end
      }
      puts
      if @intro_al_final
        Widget::introParaContinuar
      end
      return true
    end
    
    def cabecera
      puts @titulo
      puts "*" * @titulo.length      
    end
    
    def self.lanza params = {}
      l = Listado.new
      yield l
      return l.ejecuta
    end
  end

  class Editor < Widget
    
    attr_writer :validacion
    
    def initialize params = {}
      @comandos = {}
      @contexto = {}
      @validacion = nil
    end
    
    def introduceTexto
      texto = []
      while 1
        print ">>> "
        parrafo = gets.chomp.to_s
        if parrafo.match(/\\/) ## comando
          if @comandos.has_key? parrafo.slice(1..-1)
            @comandos[parrafo.slice(1..-1)].call(@contexto)
            if @contexto[:salir]
              puts "Comando #{parrafo.slice(1..-1)}"
              if @validacion
                begin 
                  @validacion.call(texto.join("\n"), @contexto)
                  break
                rescue Exception => e
                  puts "Error: #{e}"
                  return unless Widget::preguntaSiNo "Desea volver a intentarlo"
                end
              end
            end
          else
            puts "Comando #{parrafo} desconocido"
          end
        else
          texto << parrafo
        end
      end
      return texto.join("\n")
    end
    
    def comando nombre, manejador
      @comandos[nombre] = manejador
    end
    
    def self.lanza
      e = Editor.new
      yield e
      return e.introduceTexto 
    end
  end
end