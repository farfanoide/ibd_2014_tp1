PROGRAM main;
uses long_fija, crt;

procedure mostrar_resultado(var a:r_control; msj_error: string);
begin
  if (not fallo_ultima_operacion(a)) then begin
    MostrarRegistro(a.r_aux);
  end
  else begin
    writeln(msj_error);
  end;
end;

procedure cargar_registros(var a:r_control);
var
  c : char;
begin
  c := 'y';
  while (c = 'y') do begin
    CargarDesdeTeclado(a);
    writeln('desea cargar otro registro? [n para salir / y para continuar]');
    readln(c);
  end;
end;

VAR
  f : Longword;
  i : Integer;
  a : r_control;
  p : r_persona;
  n_dni: Integer;
  leido : char;
  nom_arch: String;
BEGIN

  repeat

    writeln('Seleccione una opcion:');

    writeln('a) Crear y cargar archivo.');

    writeln('b) Primero');
    writeln('c) Siguiente');
    writeln('d) Recuperar');
    writeln('e) Exportar');
    writeln('f) Insertar');
    writeln('g) Eliminar');
    writeln('h) Modificar');
    writeln('i) Respaldar');
    writeln('k) tests... ');

    writeln('j) Salir...');


    readln(leido);

    while (leido < 'a') or (leido > 'k') do begin
      writeln('Ingrese una opcion valida.');
      readln(leido);
    end;



    case (leido) of

    'a': begin
      writeln('Ingrese Nombre de archivo a crear.');
      readln(nom_arch);
      Inicializar(a, nom_arch);
      cargar_registros(a);
      GuardarCambios(a);
    end;
    'b': begin
      Primero(a);
      MostrarRegistro(a.r_aux);
    end;
    'c': begin
      Siguiente(a);
      mostrar_resultado(a, 'Fin del archivo');
    end;

    'd': begin
      write('Ingrese el DNI a recuperar:');
      read(n_dni);
      Recuperar(a, n_dni);
      mostrar_resultado(a, 'No se encontro el registro');
    end;

    'e': begin
    end;
    'f': begin
    end;
    'g': begin
    end;
    'h': begin
    end;
    'i': begin
    end;
    'k': begin
      Inicializar(a, 'test.dat');
      f := 230987;
      for i := 0 to 20 do begin
        Cargar(a, 'sarasa', i, f);
      end;
      GuardarCambios(a);
    end;


    'j': writeln('EXIT...');
  else
    writeln('default');
end;


until (leido = 'j');
END.





(* i := filesize(a.a_persona); *)
(* write(i); *)
(* f := 230987; *)
(* for i := 0 to 20 do begin *)
(*   Cargar(a, 'sarasa', i, f); *)
(* end; *)
(* i := filesize(a.a_persona); *)
(* write(i); *)
