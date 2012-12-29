require 'test/unit'

class ProbarValidadores < Test::Unit::TestCase
  require_relative "../aux_/Validacion.rb"
  
  def test_todos
    validador = Validacion::ValidadorGenerico.new
    
    ### LOGIN
    ## casos estandar permitidos
    assert_nothing_raised(Validacion::ExcepcionValidacion){validador.login "hi"}
    assert_nothing_raised(Validacion::ExcepcionValidacion){validador.login "h23423"}
    assert_nothing_raised(Validacion::ExcepcionValidacion){validador.login "h_"}
    assert_nothing_raised(Validacion::ExcepcionValidacion){validador.login "h."}    
    ## primer caracter no es una letra
    assert_raise(Validacion::ExcepcionValidacion) {validador.login "0hi"}
    ## hay espacios
    assert_raise(Validacion::ExcepcionValidacion) {validador.login "a b"}
    
    ## SIN ESPACIOS
    assert_nothing_raised(Validacion::ExcepcionValidacion){validador.sin_espacios "hola"}
    assert_raise(Validacion::ExcepcionValidacion){validador.sin_espacios "as\ts"}
    
    ## LONGITUD
    assert_nothing_raised(Validacion::ExcepcionValidacion){
      validador.longitud "123", {minimo:3}
      validador.longitud "123", {maximo:3}
      validador.longitud "123", {minimo:3, maximo:3}
    }
    assert_raise(Validacion::ExcepcionValidacion){
      validador.longitud "12", {minimo:3}
      validador.longitud "1234", {maximo:3}
      validador.longitud "1234", {minimo:3, maximo:3}
    }
    
    ## PRESENCIA
    assert_nothing_raised(Validacion::ExcepcionValidacion){
      validador.presencia 1
    }
    
    assert_raise(Validacion::ExcepcionValidacion){
      validador.presencia nil
    }
  end
end

if __FILE__ == $0
  pv = ProbarValidadores.new []
end