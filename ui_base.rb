class UIBase
  attr_accessor :flash
  
  def adios
    puts "Adios!"
  end
  
  def campo_validado campo, texto, conversor, objeto
    while true
      puts texto
      data = gets.send(conversor).chomp
      
      begin
        objeto.valida(campo, data)   
        return data
      rescue Exception => e
        puts "Campo #{campo}: #{e}"
      end
    end
  end
  
  def opcionErronea
    puts "opcion desconocida (intro para continuar)"
    gets
  end
  
  def mensajeConIntro texto
    puts texto
    puts "pulse intro para continuar"
    getc
  end
  
  def preguntaSiNo texto
    while true
      puts
      puts "#{texto} (S/n)"
      opcion = gets.chomp
      return true if opcion.empty? ## se acepta por defecto, si no se escribe nada
      if "sn".index(opcion[0].downcase) and opcion.length == 1
        return true if opcion[0].downcase == 's'
        return false 
      end
    end
  end
  
end