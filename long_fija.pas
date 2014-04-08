UNIT long_fija;

Interface
  const
    corte = -1;
  type
    r_persona = Packed Record
      Case valido : Boolean of
        True: ( nombre : String;
                dni    : Integer;
                f_nac  : Longword); (* AAAAMMDD *)
        False:(  prox  : Longword );
    end;

    f_persona = File of r_persona;

    r_control = Record
      a_persona : f_persona;
      r_aux     : r_persona;
      fallo     : Boolean;
      libre     : Longword;
      (* TODO: preguntar si es lo que esperan devolver un nro de error *)
    end;
    (* long_fija = r_control; {cuerpo del tipo exportado por el TAD} *)

  Procedure Cargar(var a:r_control; nombre:String; dni:Integer; f_nac:Longword);
  Procedure CargarDesdeRaux(var a:r_control);
  Procedure Primero(var a:r_control);
  Procedure Siguiente(var a:r_control);
  Procedure Recuperar(var a:r_control; dni:Integer);
  Procedure Exportar(var a:r_control; nom_arch_txt:String);
  Procedure Insertar(var a:r_control; nombre:String; dni:Integer; fecha:Longword);
  Procedure Eliminar(var a:r_control; dni:Integer);
  Procedure Modificar(var a:r_control; n_nombre:String; dni:Integer; n_f_nac:Longword);
  Procedure Respaldar(var a:r_control; n_archivo:String);
  Function fallo_ultima_operacion(var a:r_control): Boolean;

Implementation
  (* ========================================================= *)
  (* =====================Privados============================ *)
  (* ========================================================= *)

  Function fallo_ultima_operacion(var a:r_control): Boolean;
  begin
    fallo_ultima_operacion := a.fallo;
  end;

  procedure leer_registro(var a:f_persona; var r:r_persona);
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
  Procedure negar_registro(var r:r_persona; prox:Longword);
  begin
    r.valido := false;
    r.prox   := prox;
  end;

  (* ========================================================= *)
  (* =====================Publicos============================ *)
  (* ========================================================= *)

  Procedure Cargar(var a:r_control; nombre:String; dni:Integer; f_nac:Longword);
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

  Procedure CargarDesdeRaux(var a:r_control);
  begin
    with a do begin
      seek(a_persona, filesize(a_persona)-1);
      write(a_persona, r_aux);
      fallo := false;
    end;
  end;

  Procedure Primero(var a:r_control);
  begin
    with a do begin
      reset(a_persona);
      leer_registro(a_persona, r_aux);
      fallo := (r_aux.dni = corte);
    end;
  end;

  procedure Siguiente(var a:r_control);
  begin
    with a do begin
      leer_registro(a_persona, r_aux);
      while (not r_aux.valido) do begin
        leer_registro(a_persona, r_aux);
      end;
      fallo := (r_aux.dni = corte);
    end;
  end;

  procedure Recuperar(var a:r_control; dni:Integer);
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

  Procedure Exportar(var a:r_control; nom_arch_txt:String);
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
        if (r_aux.valido) then begin
          escupir_a_txt(txt, r_aux);
        (* TODO: preguntar como validar si registro de archivo valido|falso *)
        end;
      end;
      Close(txt);
    end;
  end;

  Procedure Insertar(var a:r_control; nombre:String; dni:Integer; fecha:Longword);
  begin
    Recuperar(a, dni);
    if (fallo_ultima_operacion(a)) then begin
      cargar(a, nombre, dni, fecha);
    end else begin
      a.fallo := true;
    end;
  end;

  Procedure Eliminar(var a:r_control; dni:Integer);
  var
    pos_eliminar : Longword;
  begin
    Recuperar(a, dni);
    (* TODO: rever tuti con cito *)
    if (not fallo_ultima_operacion(a)) then begin
      with (a) do begin
        pos_eliminar := filePos(a_persona) - 1 ;
        seek(a_persona, pos_eliminar);
        negar_registro(r_aux, libre);
        write(a_persona, r_aux);
        negar_registro(r_aux, pos_eliminar);
        reset(a_persona);
        write(a_persona, r_aux);
        libre := r_aux.prox;
        close(a_persona);
        fallo := false;
      end;
    end;
  end;

  procedure Modificar(var a:r_control; n_nombre:String; dni:Integer; n_f_nac:Longword);
  begin
    Recuperar(a, dni);
    if (not fallo_ultima_operacion(a)) then begin
      with (a) do begin
        seek(a_persona, filePos(a_persona) - 1);
        with (r_aux) do begin
          dni    := dni;
          nombre := n_nombre;
          f_nac  := n_f_nac;
        end;
        write(a_persona, r_aux);
        close(a_persona);
      end;
    end;
  end;

  Procedure Respaldar(var a:r_control; n_archivo:String);
  var
    n_arch : f_persona;
  begin
    Assign(n_arch, n_archivo);
    Rewrite(n_arch);
  end;
End.

