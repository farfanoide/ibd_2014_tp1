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

procedure inicializar(var ctl:tr_ctl, n_nomarch);
begin
  with (ctl) do begin
    assign(arch, n_nomarch);
    rewrite(arch);
    librebl := tbloque;
    ibloque := 1;
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
      move(raux.nombra, bloque[ibloque], length(raux.nombre) + 1);
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
VAR
  arch_personas : ta_personas;
  raux : tr_persona;
  sarasa : string;
  esta : integer;
BEGIN
  (* cargar_teclado(raux); *)
  (* while (raux.dni <> 0) do begin *)
  (*   escribir_registro(arch_personas, raux) *)
  (*   cargar_teclado(raux); *)
  (* end; *)
  (* cerrar_archivo(arch_personas); *)
  (* print_archivo(arch_personas); *)
  writeln('Tests: =====================================');
  sarasa := 'naoisdfnaosidnfaosidfaosdinfaosidnfoaisdnfoaisndfoaisndfoiansdfoainsdofiansdofinasdoifnasdoifnaosdifnaosdinfaois';
  esta := sizeof(sarasa);
  writeln(sizeof(esta));
  writeln(sizeof(256));
  write(sizeof(integer));
END.

