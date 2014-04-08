UNIT vieja;

Interface
  const
    corte : -1;

  type export = vieja;

  Procedure Cargar(var a:vieja; nombre:String; dni:Integer; f_nac:Longword);
  Procedure CargarDesdeRaux(var a:vieja);
  Procedure Primero(var a:vieja;);
  Procedure Siguiente(var a:vieja);
  Procedure Recuperar(var a:vieja; dni:Integer;);
  Procedure Exportar(var a:vieja; nom_arch_txt:String;);
  Procedure Insertar(var a:vieja; nombre:String; dni:Integer; fecha:Longword);
  Procedure Eliminar(var a:vieja; dni:Integer);
  (* Procedure Modificar(); *)
  (* Procedure Respaldar(); *)
  Function fallo_ultima_operacion(var a:vieja): Boolean;

Implementation (* parte privada *)
  type
    r_persona = Record
      valido : Boolean of
        true:(
          nombre : String;
          dni    : Integer;
          f_nac  : Longword); (* AAAAMMDD *)
        false:(
          prox  : Longword );
    end;

    f_persona = File of r_persona;


    r_control = Record
      a_persona : f_persona;
      r_aux     : r_persona;
      libre     : Longword;
      fallo     : Boolean;
      (* TODO: preguntar si es lo que esperan devolver un nro de error *)
    end;
    vieja = r_control; {cuerpo del tipo exportado por el TAD}


  Procedure Cargar(var a:vieja; nombre:String; dni:Integer; f_nac:Longword);
  var
  begin
    (* TODO: chequear q vaya al final *)
    with a do begin
      with r_aux do begin
        nombre := nombre;
        dni    := dni;
        f_nac  := f_nac;
      end;
      seek(a_persona, filesize(a_persona)-1);
      write(a_persona, r_aux);
      fallo := false;
    end;
  end;

  Procedure CargarDesdeRaux(var a:vieja;);
  var
  begin
    with a do begin
      seek(a_persona, filesize(a_persona)-1);
      write(a_persona, r_aux);
      fallo := false;
    end;
  end;

  Procedure Primero(var a:vieja);
  begin
    with a do begin
      reset(a_persona);
      leer_registro(a_persona, r_aux);
      fallo := (r_aux.dni = corte);
    end;
  end;

  procedure Siguiente(var a:vieja);
  begin
    with a do begin
      leer_registro(a_persona, r_aux);
      fallo := (r_aux.dni = corte);
    end;
  end;

  procedure Recuperar(var a:vieja; dni:Integer;);
  var
    encontre : Boolean;
  begin
    encontre := false;
    with (a) do begin
      reset(a_persona);
      leer_registro(a_persona, r_aux);
      while (not encontre) and (r_aux.dni <> corte) do begin
        if (r_aux.dni = dni) then begin
          encontre := true;
        end else begin
          leer_registro(a_persona, r_aux);
        end;
      end;
      fallo := not encontre;
    end;
  end;

  Procedure Exportar(var a:vieja; nom_arch_txt:String;);
  var
    txt : Text;
  begin
    Assign(txt, nom_arch_txt);
    Rewrite(txt);
    with (a) do begin
      reset(a_persona);
      while not eof(a_persona) do begin
        (* TODO: preguntar si estaria mejor usar otro reg para no pisar r_aux *)
        read(a_persona, r_aux);
        escupir_a_txt(txt, r_aux);
      end;
      Close(txt);
    end;
  end;

  Procedure Insertar(var a:vieja; nombre:String; dni:Integer; fecha:Longword);
  begin
    Recuperar(a, dni);
    if (fallo_ultima_operacion(a)) then begin
      cargar(a, nombre, dni, fecha);
    end else begin
      a.fallo := true;
    end;
  end;

  Procedure Eliminar(var a:vieja; dni:Integer);
  begin
    Recuperar(a, dni);
    (* TODO: rever tuti con cito *)
    if (not fallo_ultima_operacion(a)) then begin
      seek(a.a_persona, filePos(a.a_persona)-1);
      write(a.a_persona, a.libre);
      a.libre := filePos(a.a_persona)-1;
      reset(a_persona);
      write(a_persona, a.libre);
      close(a_persona);
      a.fallo := false;
    end;
  end;

  procedure Modificar(var a:vieja; n_nombre:String; n_dni:Integer; n_f_nac:Longword);
  begin
    Recuperar(a, dni);
    if (not fallo_ultima_operacion(a)) then begin
      with (a) do begin
        seek(a_persona, filePos(a_persona) - 1);
        with (r_aux) do begin
          dni    := n_dni;
          nombre := n_nombre;
          f_nac  := n_f_nac;
        end;
        write(a_persona, r_aux);
        close(a_persona):
      end;
    end;
  end;

(* ========================================================= *)
(* =====================Privados============================ *)
(* ========================================================= *)

  Function fallo_ultima_operacion(var a:vieja): Boolean;
  begin
    fallo_ultima_operacion := a.fallo;
  end;

  procedure leer_registro(var a:a_persona; var r:r_persona);
  begin
    if (not eof(a)) then begin
      read(a, r);
    end else begin
      r.dni := corte;
    end;
  end;
  procedure escupir_a_txt(var txt:Text; reg:r_persona);
  begin
    with (reg) do begin
      write(txt, dni);
      write(txt, f_nac);
      writeln(txt, nombre);
      (* TODO: ver si no se puede hacer todo en un solo writeln *)
    end;
  end;
End;
