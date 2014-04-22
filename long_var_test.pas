PROGRAM longvartest;

CONST
  nomarch = 'long_var';
  tbloque  = 500;
TYPE

  tr_persona = Record
    nombre: string;
    dni: integer;
  end;

  tv_personas = Array [1..tbloque] of Byte;
  ta_personas = File of tv_personas;

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
  read(reg.nombre);
  writeln('ingrese dni');
  read(reg.dni);
end;

procedure escribir_registro(var ctl:tr_ctl);
var
  tamcampo : integer;
begin
  with (ctl) do begin
    tamcampo := length(raux.nombre) + 1 + sizeof(raux.dni);
    if (librebl > tamcampo) then begin
      (* escribimos tamanio total del registro *)
      move(tamcampo, bloque[ibloque], 2);
      inc(ibloque, 2);
      (* escribimos nombre *)
      move(raux.nombre, bloque[ibloque], length(raux.nombre) + 1);
      inc(ibloque, length(raux.nombre) + 1);
      (* escribimos dni *)
      move(raux.dni, bloque[ibloque], sizeof(raux.dni));
      inc(ibloque, 2);
      dec(librebl, tamcampo);
    end else begin
      write(arch, bloque);
      inicializar_bloque(ctl);
    end;
  end;
end;

procedure cerrar_archivo(var ctl:tr_ctl);
begin
  close(ctl.arch)
end;

procedure print_archivo(var ctl:tr_ctl);
begin
  with (ctl) do begin
    reset(arch);
    while (not eof(arch)) do begin
      read(arch, bloque);
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
  cargar_teclado(raux);
  while (raux.dni <> 0) do begin
    escribir_registro(r_ctl);
    cargar_teclado(raux);
  end;
  cerrar_archivo(r_ctl);
  print_archivo(r_ctl);
  writeln('Tests: =====================================');
  sarasa := 'naoisdfnaosidnfaosidfaosdinfaosidnfoaisdnfoaisndfoaisndfoiansdfoainsdofiansdofinasdoifnasdoifnaosdifnaosdinfaois';
  writeln(length(sarasa));
  esta := sizeof(sarasa);
  writeln(sizeof(esta));
  writeln(sizeof(256));
  write(sizeof(integer));
END.

