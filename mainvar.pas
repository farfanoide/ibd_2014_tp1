PROGRAM mainvar;
uses long_var, crt;


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
  rp_aux : r_persona;
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
      write('Ingrese el nombre para exportar:');
      read(nom_arch);
      Exportar(a, nom_arch);
    end;

    'f': begin
      armar_registro(rp_aux);
      Insertar(a, rp_aux);
      if (not fallo_ultima_operacion(a)) then begin
        writeln('Registro insertado satisfactoriamente');
      end else begin
        writeln('El registro ya se encontraba en el archivo');
      end;
    end;
    'g': begin
      write('Ingrese el DNI a eliminar:');
      read(n_dni);
      Eliminar(a, n_dni);
      if (not fallo_ultima_operacion(a)) then begin
        writeln('regsitro borrado');
      end else begin
        writeln('No se encontro el registro');
      end;
      end;

    'h': begin
        armar_registro(rp_aux);
        with rp_aux do
        begin
        Modificar(a, nombre, dni, f_nac);
        mostrar_resultado(a, 'No se encontro el registro');

        end;
    end;
    'i': begin
        writeln('ingrese nombre para el nuevo archivo');
        read(nom_arch);
        Respaldar(a, nom_arch);

    end;
    'k': begin
      Inicializar(a, 'test.dat');
      f := 230987;
      reset(a.a_persona);
      for i := 0 to 20 do begin
        Cargar(a, 'sarasa', i, f);
      end;

      // GuardarCambios(a);
      reset(a.a_persona);
      read(a.a_persona, a.r_aux);
      writeln(a.r_aux.prox);
    end;


    'j': writeln('EXIT...');
  else
    writeln('default');
end;


until (leido = 'j');
END.
