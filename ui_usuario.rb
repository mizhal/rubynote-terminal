#coding: utf-8

class UIUsuario
  require_relative "aux_/Interfaz.rb"
  
  require_relative "classes/nota.rb"
  
  include Interfaz
  
  def initialize contexto
    @contexto = contexto
    @usuario = contexto[:usuario_sesion]
    @libreta = @usuario.cuenta.libretas.first
  end
  
  def flash
    "Libreta #{@libreta.nombre}"
  end
  
  def main
    Menu::lanza do |m| 
      m.titulo = "Rubynote"
      m.flash = method(:flash)
      m.opcion "Nueva Nota", method(:nuevaNota)
      m.opcion "Buscar Notas por Texto", method(:buscaNotasPorTexto)
      m.opcion "Buscar Notas por Tag", method(:buscaNotasPorTag)
      m.opcion "Ver Nota", method(:verNota)
      m.opcion "Eliminar Nota", method(:eliminaNota)
      m.opcion "Notas en orden cronológico", method(:notasCronologico)
      if @usuario.cuenta.esPremium?
        m.opcion "Cambiar de Libreta", method(:cambiaLibreta) 
        m.opcion "Nueva Libreta", method(:nuevaLibreta) 
        m.opcion "Borrar Libreta", method(:borraLibreta) 
        m.opcion "Listar Libretas", method(:listaLibretas)
        m.opcion "Buscar Libretas", method(:buscaLibretas)
      end
      m.opcion "Ver Tags", method(:listarTags)
      m.opcion "Salir", lambda {|contexto| contexto.salir = true}    
    end
  end
  
  def nuevaNota contexto
    datos_nota = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.titulo = "Crear nueva nota"
      f.campo :titulo, "Titulo de la nota", :String
      f.validaCampo :titulo, lambda { |datos, contexto|
        if datos.strip().empty?
          raise Exception.new "El título no puede estar en blanco"
        end
      }
    end
    
    return if datos_nota == nil
    
    contenido = Editor::lanza do |e|
      e.comando "salir", lambda {|contexto| contexto[:salir] = true}
      e.validacion = lambda { |datos, contexto|
        if datos.strip().empty?
          raise Exception.new "El contenido no puede estar en blanco"
        end        
      }
    end
    
    return if contenido == nil
    
    datos_tags = Formulario::lanza do |f|
      f.campo :tags, "Escriba las etiquetas para esta nota separadas por comas", :String
    end
    
    nota = Nota.crear datos_nota[:titulo], @libreta
    nota.escribe contenido
    nota.tags = datos_tags[:tags].split(",").map{ |tag|
      t = Tag.busca(tag.strip) 
      unless t
        t = Tag.crear tag.strip
      end
      t
    }
    
    nota.guarda
    
    puts "Nota creada"
    
  end
  
  def buscaNotasPorTexto contexto
    datos = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.campo :texto, "escriba el texto a buscar:", :String
      f.validaCampo :texto, lambda { |dato, contexto|
        unless dato and dato.length > 0
          raise Exception.new "No se puede dejar en blanco"
        end
      }
    end
    
    return if datos == nil
    
    notas = @libreta.buscarPorTexto datos[:texto]
    
    hay_algo = Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = notas
      l.titulo = "Listado de notas encontradas"
      l.campo :titulo
      l.campo :creado
      l.campo :tags
      l.intro_al_final = true
    end
  end
  
  def buscaNotasPorTag contexto
    datos = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.campo :tags, "escriba las tags separadas por comas:", :String
      f.validaCampo :tags, lambda { |dato, contexto|
        unless dato and dato.length > 0
          raise Exception.new "No se puede dejar en blanco"
        end
      }
    end    
    
    return if datos == nil
    
    tags = datos[:tags].split("\s*,\s*")
    
    notas = []
    tags.each{|tag|
      tag_obj = Tag.busca tag
      if tag_obj 
        tag_obj.notas.each{|nota|
          notas << nota unless notas.include? nota 
        }
      else
        puts "La etiqueta #{tag} no existe"
      end
    }
    
    Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = notas
      l.titulo = "Listado de notas por tags"
      l.campo :titulo
      l.campo :modificado
      l.campo :tags
    end
    
  end
  
  def verNota contexto
    notas = @libreta.notas.sort_by {|x| x.creado }
    hay_algo = Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = notas
      l.titulo = "Listado de notas"
      l.campo :titulo
      l.campo :creado
      l.campo :tags
      l.intro_al_final = false
    end
    return unless hay_algo

    datos = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.campo :posicion, "ahora puede elegir la nota que desea ver usando su posicion en la lista:", :Integer
      f.validaCampo :posicion, lambda { |dato, contexto|
        unless dato >= 0 and dato < notas.size
          raise Exception.new "No existe una nota en la posicion #{dato}"
        end
      }
    end
    return if datos == nil
    
    nota = notas[datos[:posicion]]
    
    puts "=============="
    puts "titulo: #{nota.titulo}"
    puts "."*("titulo: #{nota.titulo}".length)
    print "tags: "
    print nota.tags.collect(&:nombre).join(", ")
    print "\n"
    puts "=============="    
    puts nota.contenido
    puts "=============="
    Widget::introParaContinuar
  end
  
  def eliminaNota contexto
    notas = @libreta.notas.sort_by {|x| x.creado }
    hay_algo = Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = notas
      l.titulo = "Listado de notas"
      l.campo :titulo
      l.campo :creado
      l.campo :tags
      l.intro_al_final = false
    end
    return unless hay_algo

    datos = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.campo :posicion, "ahora puede elegir la nota que desea eliminar usando su posicion en la lista:", :Integer
      f.validaCampo :posicion, lambda { |dato, contexto|
        unless dato >= 0 and dato < notas.size
          raise Exception.new "No existe una nota en la posicion #{dato}"
        end
      }
    end
    return if datos == nil
    
    nota = notas[datos[:posicion]]
    @libreta.notas.delete nota
    nota.destruye
    
    puts "Nota eliminada"
  end
  
  def notasCronologico contexto    
    notas = @libreta.notas.sort_by {|x| x.modificado }
    Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = notas
      l.titulo = "Listado cronológico de notas"
      l.campo :titulo
      l.campo :modificado
      l.campo :tags
    end

  end
  
  def cambiaLibreta contexto
    hay_algo = Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = @usuario.cuenta.libretas
      l.titulo = "Libretas del Usuario"
      l.campo :nombre 
      l.intro_al_final = false        
    end
    return unless hay_algo
    
    datos = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.campo :posicion, "ahora puede elegir la libreta a la que desea cambiar usando su posicion en la lista:", :Integer
      f.validaCampo :posicion, lambda { |dato, contexto|
        unless dato >= 0 and dato < @usuario.cuenta.libretas.size
          raise Exception.new "No existe una libreta en la posicion #{dato}"
        end
      }
    end
    return if datos == nil
    
    @libreta = @usuario.cuenta.libretas[datos[:posicion]]
    puts "Abierta la libreta #{@libreta.nombre}"
  end
  
  def nuevaLibreta contexto
    datos = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.campo :nombre, "Escriba el nombre de la nueva libreta", :String
      f.validaCampo :nombre, lambda { |dato, contexto|
        if @usuario.cuenta.existeLibreta? dato
          raise Exception.new "Ya existe una libreta con el nombre '#{dato}'"
        end
      }
    end
    return if datos == nil    
    
    libreta = Libreta.crear(datos[:nombre])
    @usuario.cuenta.libretas << libreta
    libreta.guarda
    
    puts "Se ha creado la libreta #{datos[:nombre]}"
    Widget::introParaContinuar
    puts 
  end
  
  def borraLibreta contexto
    hay_algo = Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = @usuario.cuenta.libretas
      l.titulo = "Libretas del Usuario"
      l.campo :nombre 
      l.intro_al_final = false        
    end
    return unless hay_algo
    
    datos = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.campo :posicion, "ahora puede elegir la libreta a la que desea borrar usando su posicion en la lista:", :Integer
      f.validaCampo :posicion, lambda { |dato, contexto|
        unless dato >= 0 and dato < @usuario.cuenta.libretas.size
          raise Exception.new "No existe una libreta en la posicion #{dato}"
        end
      }
    end
    return if datos == nil
    
    if @usuario.cuenta.libretas.size > 1
      libreta = @usuario.cuenta.libretas[datos[:posicion]]
      @usuario.cuenta.libretas.delete_at[datos[:posicion]]
      libreta.destroy
      puts "Libreta #{libreta.nombre} eliminada"
    else
      puts "No se puede eliminar, el usuario debe tener al menos una libreta"
    end
    Widget::introParaContinuar
  end
  
  def listaLibretas contexto
    Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = @usuario.cuenta.libretas
      l.titulo = "Libretas de #{@usuario.nombre}"
      l.campo :nombre        
    end
  end
  
  def buscaLibretas contexto
    datos = Formulario::lanza :estilo_validacion => :cada_campo do |f|
      f.campo :nombre, "Escriba un texto para filtrar los nombres de las libretas", :String
      f.validaCampo :nombre, lambda { |nombre, contexto|
        unless nombre and nombre.length > 0 
          raise Exception.new "No se puede dejar en blanco"
        end
      }
    end
    
    return if datos == nil
    
    @encontradas = @usuario.cuenta.buscaLibretasPorNombre(datos[:nombre])
    
    if @encontradas.empty?
      puts "No se ha encontrado ninguna libreta"
      return
    end
    
    Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = @encontradas
      l.titulo = "Libretas de #{@usuario.nombre}"
      l.campo :nombre        
    end    
  end
  
  def listarTags contexto
    Listado::lanza do |l|
      l.tam_pagina = 5
      l.coleccion = @libreta.tags.keys.sort_by {|x| x.nombre}
      l.titulo = "Listado de etiquetas"
      l.campo :nombre
    end

  end 
    
    
end