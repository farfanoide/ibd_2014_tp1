PROGRAM longvartest;

CONST
  nomarch = 'long_var';
  tbloque  = 500;
TYPE

  tr_persona = Record
    nombre: string;
    dni: integer;
  end;

  tv_persona  = Array [1..100] of Byte; // vector para menejo de registro unico
  tv_personas = Array [1..tbloque] of Byte; // bloque de registros variables
  ta_personas = File of tv_personas; // archivo de bloques

  tr_ctl = Record
    bloque  : tv_personas;
    ibloque : integer;
    librebl : integer;
    raux    : tr_persona;
    arch    : ta_personas;
  end;

procedure inicializar_bloque(var ctl:tr_ctl);
begin
  with (ctl) do begin
    librebl := tbloque;
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

procedure print_registro(r:tr_persona);
begin
  with r do begin
    writeln('nombre: ' + nombre);
    writeln('dni: ', dni);
    writeln('--------------------------------');
  end;
end;

procedure escribir_registro(var ctl:tr_ctl);
var
  tamcampo : integer;
begin
  with (ctl) do begin
    tamcampo := length(raux.nombre) + 1 + sizeof(raux.dni);
    (* if (librebl > tamcampo) then begin *)
    (* escribimos tamanio total del registro *)
    move(tamcampo, bloque[ibloque], sizeof(tamcampo));
    inc(ibloque, sizeof(tamcampo));

    (* escribimos nombre *)
    move(raux.nombre, bloque[ibloque], length(raux.nombre) + 1);
    inc(ibloque, length(raux.nombre) + 1);

    (* escribimos dni *)
    move(raux.dni, bloque[ibloque], sizeof(raux.dni));
    inc(ibloque, sizeof(tamcampo));

    (* reducimos escpacio libre del bloque *)
    dec(librebl, tamcampo);
    (* end else begin *)
    (*   write(arch, bloque); *)
    (*   inicializar_bloque(ctl); *)
    (* end; *)
  end;
end;

Procedure imprimir_bloque(var ctl:tr_ctl);
var
  v : tv_personas;
  n : string[30];
  d,i,tr : integer;
begin
  v := ctl.bloque;

  i := 1;
  while i < 100 do begin
    writeln('------------------------------------');
    (* sacamos tamanio registro completo *)
    move(v[i], tr, sizeof(tr));
    inc(i, sizeof(tr));
    writeln('tamanio de tr: ', tr);

    (* sacamos tamanio nombre *)
    move(v[i], tr, 1);
    writeln('tamanio de nombre: ', tr);
    move(v[i], n, tr+1);
    writeln('nombre: ', n);
    inc(i, tr + 1);

    (* sacamos dni *)
    move(v[i], d, sizeof(d));
    writeln('dni: ', d);
    inc(i, sizeof(d));
    writeln('------------------------------------');
  end;
end;
Procedure cargar_reg_en_raux(var ctl:tr_ctl);
var
  v : tv_personas;
  n : string[30];
  d,i,tr : integer;
begin
  v := ctl.bloque;

  i := ctl.ibloque;
  writeln('------------------------------------');
  (* sacamos tamanio registro completo *)
  move(v[i], tr, sizeof(tr));
  inc(i, sizeof(tr));
  writeln('tamanio de tr: ', tr);

  (* sacamos tamanio nombre *)
  move(v[i], tr, 1);
  writeln('tamanio de nombre: ', tr);
  move(v[i], n, tr+1);
  writeln('nombre: ', n);
  inc(i, tr + 1);
  ctl.raux.nombre := n;

  (* sacamos dni *)
  move(v[i], d, sizeof(d));
  writeln('dni: ', d);
  inc(i, sizeof(d));
  ctl.raux.dni := d;
  writeln('------------------------------------');
  ctl.ibloque := i;
end;

Procedure armar_reg_desde_vect(var raux:tr_persona; var v_reg:tv_persona);
var
  ipersona: integer;
  tamcampo: integer;
  tamreg  : integer;
begin
  ipersona := 1;
  // leo el tamaño del registro completo
  move(v_reg[ipersona], tamreg,  sizeof(tamreg));
  inc(ipersona, sizeof(tamreg));

  // leo el tamaño del nombre y el nombre
  move(v_reg[ipersona], tamcampo, 1);
  move(v_reg[ipersona], raux.nombre, tamcampo + 1);
  inc(ipersona, tamcampo + 1); //aumento el indice con el tamanio del nombre


  // leo en raux el dni
  move(v_reg[ipersona], raux.dni, sizeof(raux.dni));
  inc(ipersona, sizeof(raux.dni)); //aumento el indice con el tamanio del dni
end;

Procedure procesar_registro(var ctl:tr_ctl);
var
  tamreg: integer;
  vect_aux: tv_persona;
begin
  with (ctl) do begin
    // leo el tamaño del registro
    writeln('tamos procesando el reg');
    // si es negativo
    // aumento indice y salto al proximo
    //sino
    cargar_reg_en_raux(ctl);
  end;
end;

procedure leer_registro(var ctl: tr_ctl);
begin

  writeln('llegamos a leer un reg');
  with (ctl) do begin
    // si no quedan registros en el bloque cargo otro bloque, sino leo
    if (ibloque >= (tbloque - librebl) ) then begin
      //termino el archivo,
      writeln('hay bloqeu');

      if (not eof(arch)) then begin
        writeln('no se termino el arch');
        //leer bloque de arch
        // ver si hay q guardar algo
        read(arch, bloque);
        ibloque := 1;

        procesar_registro(ctl);
      end else begin
        // no hay mas bloques, ni registros.
        writeln('No hay bloques ni registros.');
        raux.dni := -1;
      end ;
    end else begin
      procesar_registro(ctl);
    end;
  end;
end;


procedure cerrar_archivo(var ctl:tr_ctl);
begin
  //TODO: si modifique el bloque buffer y esta en modo de escritura
  // tengo que escribirlo a disco antes.

  close(ctl.arch);

  // estado := cerrado.
end;


procedure print_archivo(var ctl:tr_ctl);
begin
  with (ctl) do begin
    reset(arch);
    ibloque := 1;
    read(arch, bloque);
    writeln('reseteamos todo el archivo');
    leer_registro(ctl);

    while (raux.dni <> -1) do begin
      print_registro(raux);
      leer_registro(ctl);
    end;
  end;
end;

VAR
  arch_personas : ta_personas;
  raux : tr_persona;
  sarasa : string;
  esta : integer;
  r_ctl :tr_ctl;

BEGIN

  cargar_teclado(r_ctl.raux);

  inicializar(r_ctl, 'sarasa');
  while (r_ctl.raux.dni <> 0) do begin
    escribir_registro(r_ctl);
    cargar_teclado(r_ctl.raux);
  end;

  r_ctl.ibloque :=1;
  procesar_registro(r_ctl);
  writeln('imprimiendo raux');
  print_registro(r_ctl.raux);

  procesar_registro(r_ctl);
  writeln('imprimiendo raux 2');
  print_registro(r_ctl.raux);

  (* with r_ctl do begin *)
  (*   write(arch, bloque); *)
  (* end; *)
  (* cerrar_archivo(r_ctl); *)
  (*  *)
  (* print_archivo(r_ctl); *)
  (*  *)

  writeln('Tests: =====================================');
  sarasa := 'naoisdfnaosidnfaosidfaosdinfaosidnfoaisdnfoaisndfoaisndfoiansdfoainsdofiansdofinasdoifnasdoifnaosdifnaosdinfaois';
  writeln(length(sarasa));
  esta := sizeof(sarasa);
  writeln(sizeof(esta));
  writeln(sizeof(256));
  write(sizeof(integer));
END.



