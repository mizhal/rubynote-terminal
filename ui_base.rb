class UIBase
 
  attr_accessor :flash
  
  def adios()
    puts "Adios!"
  end

  def mensajeConIntro(texto)
    puts texto
    puts "pulse intro para continuar"
    getc
  end
end