PROGRAM longvartest;

CONST
  nomarch = 'long_var';
  tbloque  = 17;
  corte = -1;
TYPE

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

procedure print_registro(r:tr_persona);
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
  vect_aux: tv_persona;
begin
  with (ctl) do begin

    move(bloque[ibloque], tamreg, sizeof(tamreg));

    if (tamreg >= 1) then begin
      
      cargar_reg_en_raux(ctl);
    end
    else begin
        // VER SI ESTA BIENNNN
        
    end;

    // leo el tamaño del registro
    // si es negativo
    // aumento indice y salto al proximo
    //sino


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

Procedure Primero(var ctl:tr_ctl);
{busca el primer registro del archivo, espera q el archivo haya sido guardado previamente}
begin
  reset(ctl.arch);
  
  Leer_Bloque(ctl);
  // TODO: ver que pasa si el archivo esta vacio (o tiene todos los registros borrados por ej.)
  // donde lo controlamos?
  procesar_registro(ctl);

end;

procedure siguiente(var ctl: tr_ctl);
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
  (* TODO: utilizar metodos propios *)
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
   encontre : Boolean;
 begin 
   encontre := false;
   // TODO: rever tuti con cito 
   if Recuperar(ctl, dni) then begin 

     encontre := true;

     with (ctl) do begin 

      // me posiciono antes del reg a eliminar (que es el recuperado)
      ibloque := ibloque - regsize(raux);

      (* leo tamanio registro completo *)
      move(bloque[ibloque], tamcampo, sizeof(tamcampo));

      // negativizo
      tamcampo := tamcampo * -1;

      (* escribimos registro borrado *)
      move(tamcampo, bloque[ibloque], sizeof(tamcampo));
      
     end ;
     end;

    Eliminar := encontre; 
     
 end; 





// procedure print_archivo(var ctl:tr_ctl);
// begin
  //   with (ctl) do begin
    //     reset(arch);
    //     ibloque := 1;
    //     read(arch, bloque);
    //     writeln('reseteamos todo el archivo');
    //     siguiente(ctl);

    //     while (raux.dni <> corte) do begin
      //       print_registro(raux);
      //       siguiente(ctl);
      //     end;
      //   end;
      // end;

VAR
  arch_personas : ta_personas;
  raux : tr_persona;
  sarasa : string;
  esta, cont : integer;
  dni: Longint;
  r_ctl :tr_ctl;

BEGIN
  inicializar(r_ctl, 'sarasa');


  cargar_teclado(r_ctl.raux);

  while (r_ctl.raux.dni <> 0) do begin

    escribir_registro(r_ctl);
    writeln(r_ctl.ibloque, ' ibloque dsp de escribir el reg.');

    // writeln('tamanio del dni ', sizeof(r_ctl.raux.dni));
    // writeln('tamanio del nombre ', length(r_ctl.raux.nombre)+1);
    // writeln('tamanio de registro:', regsize(r_ctl.raux));
    // writeln('librebl: ', r_ctl.librebl);
    // writeln('__________________________________');

    cargar_teclado(r_ctl.raux);

  end;


  Escribir_bloque_a_disco(r_ctl);
  cerrar_archivo(r_ctl);
  (* print_archivo(r_ctl); *)

  // recuperar FUNCIONA PERFECTO.

  writeln('=======================');
  writeln('ingrese dni a recuperar:');
  readln(dni);

  if (recuperar(r_ctl, dni)) then begin
    print_registro(r_ctl.raux);

  end else begin
    writeln('no se ncontro el reg');

  end;

  // FIN RECUPERAR.

  // BORRAR

  writeln(r_ctl.ibloque, ' es la pos de ibloque dsp de recuperar');

  // vuelvo atras registro actual.
  r_ctl.ibloque := r_ctl.ibloque - regsize(r_ctl.raux);

  // cambio el dni por -dni
  // escribo raux.  


  siguiente(r_ctl);
  writeln('reg recien leido:: ');
  print_registro(r_ctl.raux);
  
  
  (* writeln('Tests: ====================================='); *)

  //imprimir todo
  (* reset(r_ctl.arch); *)
  (*  *)
  (* Leer_Bloque(r_ctl); *)
  (*  *)
      // falta leer primero, (registro)
  (* cont := 1; *)
  (*  *)
  (* while (r_ctl.raux.dni <> corte) do begin *)
  (*  *)
  (*   siguiente(r_ctl); *)
  (*  *)
  (*   if (r_ctl.raux.dni <> corte) then begin *)
  (*     writeln('Registro ', cont, ': '); *)
  (*     print_registro(r_ctl.raux); *)
  (*     // writeln('Aca ibloque es:', r_ctl.ibloque); *)
  (*     // writeln('Aca librebl es:', r_ctl.librebl); *)
  (*  *)
  (*   end; *)
  (*  *)
  (*   inc(cont, 1); *)
  (*  *)
  (* end; *)
  (*  *)
  (* test procesar_registro *)

  // siguiente(r_ctl);
  // writeln('imprimiendo raux 2');
  // print_registro(r_ctl.raux);

  (* sarasa := 'naoisdfnaosidnfaosidfaosdinfaosidnfoaisdnfoaisndfoaisndfoiansdfoainsdofiansdofinasdoifnasdoifnaosdifnaosdinfaois'; *)
  (* writeln(length(sarasa)); *)
  (* esta := sizeof(sarasa); *)
  (* writeln(sizeof(esta)); *)
  (* writeln(sizeof(256)); *)
  (* write(sizeof(integer)); *)
END.