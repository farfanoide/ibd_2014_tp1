UNIT long_fija;

Interface

type
  r_persona =  Record
    nombre : String;
    dni    : Integer;
    f_nac  : Longword; (* AAAAMMDD *)
    prox   : Integer;
    valido : Boolean;
    end;

    f_persona = File of r_persona;

    r_control = Record
      a_persona : f_persona;
      r_aux     : r_persona;
      fallo     : Boolean;
      libre     : Integer;
      (* TODO: preguntar si es lo que esperan devolver un nro de error *)
    end;
    (* long_fija = r_control; {cuerpo del tipo exportado por el TAD} *)

Procedure Inicializar(var a:r_control; a_nom:String);
procedure armar_registro(var r:r_persona);
Procedure Cargar(var a:r_control; n_nombre:String; n_dni:Integer; n_f_nac:Longword);
Procedure CargarDesdeRegistro(var a:r_control; r:r_persona);
procedure CargarDesdeTeclado(var a:r_control);
Procedure Primero(var a:r_control);
Procedure Siguiente(var a:r_control);
Procedure Recuperar(var a:r_control; dni:Integer);
Procedure Exportar(var a:r_control; nom_arch_txt:String);
Procedure Insertar(var a:r_control; r:r_persona);
Procedure Eliminar(var a:r_control; dni:Integer);
Procedure Modificar(var a:r_control; n_nombre:String; dni:Integer; n_f_nac:Longword);
Procedure Respaldar(var a:r_control; n_archivo:String);
Procedure GuardarCambios(var a:r_control);
Procedure MostrarRegistro(var r:r_persona);
Function fallo_ultima_operacion(var a:r_control): Boolean;

Implementation
(* ========================================================= *)
(* =====================Privados============================ *)
(* ========================================================= *)

const
  corte = -1;

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
    writeln(txt, f_nac, dni, nombre);
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

Procedure Inicializar(var a:r_control; a_nom:String);
begin
  with (a) do begin
    Assign(a_persona, a_nom);
    Rewrite(a_persona);
    negar_registro(r_aux, -1);
    write(a_persona, r_aux);

    libre := -1;
    fallo := false;
  end;
  // GuardarCambios(a);
end;

Procedure Cargar(var a:r_control; n_nombre:String; n_dni:Integer; n_f_nac:Longword);
begin
  with (a) do begin
    r_aux.valido := true;
    r_aux.nombre := n_nombre;
    r_aux.dni    := n_dni;
    r_aux.f_nac  := n_f_nac;
    seek(a_persona, filesize(a_persona));
    write(a_persona, r_aux);
    fallo := false;
  end;
end;

Procedure CargarDesdeRegistro(var a:r_control; r:r_persona);
begin
  with a do begin
    r.valido := true;
    write(a_persona, r);
    fallo := false;
  end;
end;

procedure armar_registro(var r:r_persona);
begin
  with (r) do begin
    writeln('Ingrese nombre:');
    readln(nombre);
    writeln('INgrese dni:');
    readln(dni);
    writeln('INgrese fecha de nacimiento:');
    readln(f_nac);
  end;
end;

procedure CargarDesdeTeclado(var a:r_control);
begin
  armar_registro(a.r_aux);
  CargarDesdeRegistro(a, a.r_aux);
end;

procedure Siguiente(var a:r_control);
begin
  with (a) do begin
    leer_registro(a_persona, r_aux);
    while (not r_aux.valido) do begin
      leer_registro(a_persona, r_aux);
    end;
    fallo := (r_aux.dni = corte);
  end;
end;

Procedure Primero(var a:r_control);
begin
  with (a) do begin
    reset(a_persona);
    Siguiente(a);
    fallo := (r_aux.dni = corte);
  end;
end;

procedure Recuperar(var a:r_control; dni:Integer);
var
  encontre : Boolean;
begin
  (* TODO: utilizar metodos propios *)
  encontre := false;
  with (a) do begin
    reset(a_persona);
    leer_registro(a_persona, r_aux);
    while (not encontre) and (r_aux.dni <> corte) do begin
      if (r_aux.dni = dni) and (r_aux.valido) then begin
        encontre := true;
      end else begin
        leer_registro(a_persona, r_aux);
      end;
    end;
    fallo := not encontre;
  end;
end;

Procedure MostrarRegistro(var r:r_persona);
begin
  with (r) do begin
    writeln('Nombre: ', nombre);
    writeln('Dni: ', dni);
    writeln('Fecha de Nacimiento: ', f_nac);
    writeln('*-------------------------------------------*');
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
      writeln('grabando a ', r_aux.dni);
      if (r_aux.valido) then begin
        escupir_a_txt(txt, r_aux);
        (* TODO: preguntar como validar si registro de archivo valido|falso *)
      end;
    end;
  end;
  Close(txt);
end;

Procedure BuscarProximoLibre(var a:r_control);
var
  pos : Integer;
begin
  with (a) do begin


    if (libre = -1) then begin

      seek(a_persona, filesize(a_persona));

    end else begin

        writeln('llegamso hasta aca2');
      pos := libre;
      seek(a_persona, libre);
      read(a_persona, r_aux);
      seek(a_persona, 0);
      write(a_persona, r_aux);
      libre := r_aux.prox;
      seek(a_persona, pos -1);
    end;
  end;
end;

Procedure Insertar(var a:r_control; r:r_persona);
begin
  Recuperar(a, r.dni);
  if (fallo_ultima_operacion(a)) then begin
    BuscarProximoLibre(a);

    CargarDesdeRegistro(a, r);
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
  with (a) do begin
  while (not eof(a_persona)) do begin
    read(a_persona, r_aux);
    if (r_aux.valido) then begin
      write(n_arch, r_aux);
    end;
  end;
  end;
  close(n_arch);
end;

Procedure GuardarCambios(var a:r_control);
begin
  close(a.a_persona);
end;

End.

