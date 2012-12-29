require_relative './usuario.rb'

class UsuarioAdmin < Usuario
  def admin?
    return true
  end
end