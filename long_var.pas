UNIT long_var;

Interface

const
  tbloque  = 17;
  corte = -1;

type

  tr_persona = Record
    nombre: string;
    dni: Longint;
  end;

  tv_persona  = Array [1..100] of Byte; // vector para menejo de registro unico
  tv_personas = Array [1..tbloque] of Byte; // bloque de registros variables

  tr_bloque = Record
    bloque : tv_personas;
    free: integer;
  end;

  ta_personas = File of tr_bloque; // archivo de bloques

  tr_ctl = Record
    bloque  : tv_personas;
    ibloque : integer;
    librebl : integer;
    raux    : tr_persona;
    arch    : ta_personas;
  end;

procedure inicializar(var ctl:tr_ctl; n_nomarch:string);
procedure Cargar(var ctl:tr_ctl; n_nom:string; n_dni:Longint);
(* Procedure CargarDesdeRegistro(var a:tr_ctl; r:r_persona); *)
(* procedure CargarDesdeTeclado(var a:tr_ctl); *)
Procedure Primero(var ctl:tr_ctl);
procedure siguiente(var ctl:tr_ctl);
function Recuperar(var ctl:tr_ctl; dni:longint):Boolean;
(* Procedure Exportar(var a:tr_ctl; nom_arch_txt:String); *)
(* Procedure Insertar(var a:tr_ctl; r:r_persona); *)
function Eliminar(var ctl: tr_ctl; dni:Longint): Boolean;
(* Procedure Modificar(var a:tr_ctl; n_nombre:String; dni:Integer; n_f_nac:Longword); *)
(* Procedure Respaldar(var a:tr_ctl; n_archivo:String); *)
(* Procedure GuardarCambios(var a:tr_ctl); *)
procedure MostrarRegistro(r:tr_persona);

Implementation
(* ========================================================= *)
(* =====================Privados============================ *)
(* ========================================================= *)

procedure inicializar_bloque(var ctl:tr_ctl);
begin
  with (ctl) do begin
    librebl := tbloque;
    (* for ibloque:=1 to tbloque do begin *)
    (*   bloque[ibloque] := 0; *)
    (* end; *)
    ibloque := 1;
  end;
end;

procedure inicializar(var ctl:tr_ctl; n_nomarch:string);
begin
  with (ctl) do begin
    assign(arch, n_nomarch);
    rewrite(arch);
    inicializar_bloque(ctl);
  end;
end;

procedure cargar_teclado(var reg:tr_persona);
begin
  writeln('ingrese nombre');
  readln(reg.nombre);
  writeln('ingrese dni');
  readln(reg.dni);
end;

procedure MostrarRegistro(r:tr_persona);
begin
  with r do begin
    writeln('nombre: ' + nombre);
    writeln('dni: ', dni);
    writeln('--------------------------------');
  end;
end;

function regsize(r:tr_persona):integer;
begin
  regsize := length(r.nombre) + 1 + sizeof(r.dni) + 2;
end;

procedure Escribir_bloque_a_disco(ctl: tr_ctl);
var aux : tr_bloque;
begin
  aux.bloque := ctl.bloque;
  aux.free := ctl.librebl;
  write(ctl.arch, aux);
end;

procedure escribir_registro(var ctl :tr_ctl);
var
  tamcampo : integer;
  tamdni : Longint;
begin
  with (ctl) do begin
    (* tamcampo := length(raux.nombre) + 1 + sizeof(raux.dni); *)
    tamcampo := regsize(raux);
    writeln('Tamaño del reg: ', tamcampo);

    if (librebl >= tamcampo) then begin
      (* escribimos tamanio total del registro *)
      move(tamcampo, bloque[ibloque], sizeof(tamcampo));
      inc(ibloque, sizeof(tamcampo));

      (* escribimos nombre *)
      move(raux.nombre, bloque[ibloque], length(raux.nombre) + 1);
      inc(ibloque, length(raux.nombre) + 1);

      (* escribimos dni *)
      move(raux.dni, bloque[ibloque], sizeof(raux.dni));
      inc(ibloque, sizeof(tamdni));

      (* reducimos escpacio libre del bloque *)
      dec(librebl, tamcampo);

    end else begin


      Escribir_bloque_a_disco(ctl);
      inicializar_bloque(ctl);

      (* escribimos tamanio total del registro *)
      move(tamcampo, bloque[ibloque], sizeof(tamcampo));
      inc(ibloque, sizeof(tamcampo));

      (* escribimos nombre *)
      move(raux.nombre, bloque[ibloque], length(raux.nombre) + 1);
      inc(ibloque, length(raux.nombre) + 1);

      (* escribimos dni *)
      move(raux.dni, bloque[ibloque], sizeof(raux.dni));
      inc(ibloque, sizeof(tamdni));

      (* reducimos escpacio libre del bloque mas dos que ocupa el espacio*)
      dec(librebl, tamcampo);
    end;
  end;
end;

procedure Cargar(var ctl:tr_ctl; n_nom:string; n_dni:Longint);
begin
  with ctl do begin
    raux.nombre := n_nom;
    raux.dni := n_dni;
  end;
  escribir_registro(ctl);
end;

Procedure cargar_reg_en_raux(var ctl:tr_ctl);
var
  v : tv_personas;
  n : string[30];
  i,tr : integer;
  d : Longint;
begin
  v := ctl.bloque;
  i := ctl.ibloque;

  (* sacamos tamanio registro completo *)
  move(v[i], tr, sizeof(tr));
  inc(i, sizeof(tr));


  (* sacamos tamanio nombre *)
  move(v[i], tr, 1);

  move(v[i], n, tr+1);
  inc(i, tr + 1);

  ctl.raux.nombre := n;

  (* sacamos dni *)

  move(v[i], d, sizeof(d));

  inc(i, sizeof(d));
  ctl.raux.dni := d;


  ctl.ibloque := i;

end;

Procedure procesar_registro(var ctl:tr_ctl);
var
  tamreg: integer;

begin
  with (ctl) do begin
    move(bloque[ibloque], tamreg, sizeof(tamreg));

    if (tamreg >= 1) then begin
      cargar_reg_en_raux(ctl);
    end else begin
      raux.dni := -2;
      ibloque := ibloque + regsize(raux);
    end;
  end;
end;

procedure Leer_Bloque(var ctl: tr_ctl);
var aux :tr_bloque;
begin
  read(ctl.arch, aux);
  ctl.bloque := aux.bloque;
  ctl.librebl := aux.free;
  ctl.ibloque := 1;

end;

procedure avanzar(var ctl: tr_ctl);
begin

  with (ctl) do begin
    // si no quedan registros en el bloque cargo otro bloque, sino leo
    if (ibloque >= (tbloque - librebl) ) then begin
      //termino el archivo,

      if (not eof(arch)) then begin
        //writeln('=====================');
        //leer bloque de arch
        // ver si hay q guardar algo

        Leer_Bloque(ctl);
        procesar_registro(ctl);

      end else begin
        // no hay mas bloques, ni registros.
        writeln('Fin archivo');
        raux.dni := corte;

      end ;
    end else begin
      //writeln('---------------------------');
      procesar_registro(ctl);
    end;
  end;
end;

procedure siguiente(var ctl:tr_ctl);
begin
  avanzar(ctl);

  while (ctl.raux.dni = -2) and (ctl.raux.dni <> corte) do begin

    avanzar(ctl);

  end;
end;

Procedure Primero(var ctl:tr_ctl);
{busca el primer registro del archivo, espera q el archivo haya sido guardado previamente}
begin
  reset(ctl.arch);

  Leer_Bloque(ctl);
  // TODO: ver que pasa si el archivo esta vacio (o tiene todos los registros borrados por ej.)
  // donde lo controlamos?
  siguiente(ctl);

end;

procedure cerrar_archivo(var ctl:tr_ctl);
begin
  //TODO: si modifique el bloque buffer y esta en modo de escritura
  // tengo que escribirlo a disco antes.

  close(ctl.arch);

  // estado := cerrado.
end;


function Recuperar(var ctl:tr_ctl; dni:longint):Boolean;
var
  encontre : Boolean;
begin
  encontre := false;

  Primero(ctl);

  while (not encontre) and (ctl.raux.dni <> corte) do begin

    if (ctl.raux.dni = dni) then begin
      encontre := true;
    end else begin

      siguiente(ctl);
    end;
  end;
  Recuperar:= encontre;
end;


function Eliminar(var ctl: tr_ctl; dni:Longint): Boolean;
var
  tamcampo : integer;
  tamdni : Longint;
  encontre : Boolean;
begin
  encontre := false;

  // TODO: rever tuti con cito
  if (recuperar(ctl, dni)) then begin

    encontre := true;

    with (ctl) do begin
      tamcampo := regsize(raux);
      tamcampo := tamcampo * -1;

      // me posiciono antes del reg a eliminar (que es el recuperado)
      ibloque := ibloque - regsize(raux);

      (* escribimos tamanio total del registro *)
      move(tamcampo, bloque[ibloque], sizeof(tamcampo));
      inc(ibloque, sizeof(tamcampo));

      (* escribimos nombre *)
      move(raux.nombre, bloque[ibloque], length(raux.nombre) + 1);
      inc(ibloque, length(raux.nombre) + 1);

      (* escribimos dni *)
      tamdni := sizeof(raux.dni);
      move(raux.dni, bloque[ibloque], sizeof(raux.dni));
      inc(ibloque, sizeof(tamdni));



      seek(arch, filepos(arch)-1);
      Escribir_bloque_a_disco(ctl);





      // me posiciono antes del reg a eliminar (que es el recuperado)
      // ibloque := ibloque - regsize(raux);

      // (* leo tamanio registro completo *)
      // move(bloque[ibloque], tamcampo, sizeof(tamcampo));

      // // negativizo

      // (* escribimos registro borrado *)
      // move(tamcampo, bloque[ibloque], sizeof(tamcampo));
      // sobreescribimos bloque en disco
    end;
  end;

  Eliminar := encontre;

end;

function Insertar(var ctl:tr_ctl; n: string; dni : Longint): boolean;
var
  esta : boolean;
begin
  esta := recuperar(ctl, dni);

  if not(esta) then begin
    with (ctl) do begin
      raux.nombre := n;
      raux.dni := dni;
      escribir_registro(ctl);

      Escribir_bloque_a_disco(ctl);
    end;
  end;
  Insertar := not(esta);
end;

function Modificar(var ctl : tr_ctl; n: string; dni : Longint):Boolean;
var
  tamcampo: integer;
  elimine :boolean;
begin
  elimine := eliminar(ctl, dni);

  if (elimine) then begin

    with (ctl) do begin

      raux.nombre := n;
      raux.dni := dni;
      escribir_registro(ctl);

      Escribir_bloque_a_disco(ctl);

    end;

  end;


  Modificar:= elimine;
end;

End.

