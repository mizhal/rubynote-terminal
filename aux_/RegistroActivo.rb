module RegistroActivo
  
  def guarda
    self.dependientes { |dependientes| dependientes.guarda }
    Archivo.instance().registra self
  end
  
  def destruye
    unless self.cuenta_referencias > 0
      self.dependientes { |dependientes| dependientes.destroy }
      Archivo.instance().elimina self
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
  
end