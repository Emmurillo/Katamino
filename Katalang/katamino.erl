-module(katamino).
-export([katamino/3]).




%%----  ██████╗ ███████╗███████╗ ██████╗ ██╗    ██╗   ██╗███████╗██████╗ 
%%----  ██╔══██╗██╔════╝██╔════╝██╔═══██╗██║    ██║   ██║██╔════╝██╔══██╗
%%----  ██████╔╝█████╗  ███████╗██║   ██║██║    ██║   ██║█████╗  ██████╔╝
%%----  ██╔══██╗██╔══╝  ╚════██║██║   ██║██║    ╚██╗ ██╔╝██╔══╝  ██╔══██╗
%%----  ██║  ██║███████╗███████║╚██████╔╝███████╗╚████╔╝ ███████╗██║  ██║
%%----  ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝ ╚═══╝  ╚══════╝╚═╝  ╚═╝
%%----                                                      
katamino(ArchivoLectura,N,M) -> resolver(N,M, 
	katamino(nueva_pila(), parsear(
		spl_lista(
			leer_Archivo(
				lee_linea(ArchivoLectura))),1), N, M) , 'Soluciones').
katamino(Pila,Leido,N,M) -> inicioBackt(
									ramaInicial(N,M,Leido,Pila),[]).             

resolver(N,M,Soluciones,File)-> file:write_file(               %Formato de escritura
											File,io_lib:fwrite("~pX~p\n~p\n",[N,M,Soluciones])).

%%----  ██╗      ██████╗  ██████╗ ██╗ ██████╗ █████╗ 
%%----  ██║     ██╔═══██╗██╔════╝ ██║██╔════╝██╔══██╗
%%----  ██║     ██║   ██║██║  ███╗██║██║     ███████║
%%----  ██║     ██║   ██║██║   ██║██║██║     ██╔══██║
%%----  ███████╗╚██████╔╝╚██████╔╝██║╚██████╗██║  ██║
%%----  ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝
%%----                             

ramaInicial(_,_, [], Pila) -> Pila;

ramaInicial(N,M, Fichas, Pila) -> push_aux(
									Pila, 
									verOtrasRamas(N,M,erlang:hd(Fichas),erlang:tl(Fichas)) ).

verOtrasRamas(N,M, Ficha, DemasFichas) -> otrasRamas(N,M, ramasOptimas(Ficha), DemasFichas). 

otrasRamas(_,_, [], _) -> [];
otrasRamas(N,M, ListaHijos, RamasRestantes) -> posiblesPosiciones(N,M, erlang:hd(ListaHijos), RamasRestantes) ++ otrasRamas(N,M, erlang:tl(ListaHijos), RamasRestantes).

ramasOptimas(F) -> rotacionesValidas(hijosRaiz(F)).

inicioBackt({elem,[]},Soluciones) -> Soluciones;
inicioBackt(Pila,Soluciones) -> backt( vaciarPila(
												segundo(pop(Pila))) , segundo(pop(Pila)) , primero(pop(Pila)), Soluciones).
backt(true, {Matriz,_} , Pila, Soluciones) -> inicioBackt(Pila, Soluciones ++ [Matriz]);
backt(false, Padre , Pila, Soluciones) -> inicioBackt( push_aux(Pila,generaHijos(Padre))  , Soluciones).
primero(L) -> erlang:hd(L).
segundo(L) -> erlang:hd(erlang:tl(L)).
generaHijos(P) -> flatten(generaHijosAux(P)).

generaHijosAux({Matriz, []}) -> [{Matriz, []}]; 
generaHijosAux({Matriz, Fichas}) -> [cambioFicha(Matriz, Rotacion, erlang:tl(Fichas)) || Rotacion <- ramasOptimas(erlang:hd(Fichas))].

rotacionesValidas([]) -> [];
rotacionesValidas([M|[]]) -> [M];
rotacionesValidas([M1|T]) -> rotacionesValidasAux( estaRepetido(M1,T), M1, T ).

estaRepetido(_,[]) -> false;
estaRepetido(F,[H|T]) -> estaRepetidoAux(matricesIgualesAux(F,H), F, T).

estaRepetidoAux(true, _, _) -> true;
estaRepetidoAux(false, _, []) -> false;
estaRepetidoAux(false, F, [H|T]) -> estaRepetidoAux(matricesIgualesAux(F,H), F, T).

ubicarSolucion(M,F,X,Y) -> ubicarSolucionAux( ubicarPiezas(X,Y,F) ,M).
ubicarSolucionAux([],M) -> M;
ubicarSolucionAux(Lista, M) -> ubicarSolucionAux(erlang:tl(Lista), insertaFigura(erlang:hd(Lista), M, 0)).

insertaFigura([],_,_)-> []; 
insertaFigura([X,Y,Z],[H|T],Y)-> [reemplazarFila(X,Z,H)|T];
insertaFigura([X,Y,Z],[H|T],A)-> [H|insertaFigura([X,Y,Z],T,A+1)].

reemplazarFila(_,0,L)->L; 
reemplazarFila(Y,E,L)-> {HeadList, [_|TailList]} = lists:split(Y, L), lists:append([HeadList, [E|TailList]]).

ubicarPiezas(_,_,[]) -> []; %% Generar lista de coordenadas-valor 
ubicarPiezas(X,Y,M) -> lists:append( ubicarColumna(X,Y,erlang:hd(M)) , ubicarPiezas(X,Y+1,erlang:tl(M))).

ubicarColumna(_,_,[]) -> [];
ubicarColumna(X,Y,Fila) -> [[X,Y,erlang:hd(Fila)] | ubicarColumna(X+1,Y,erlang:tl(Fila)) ]. 

posiblesPosiciones(N,M, Rotacion, RamasRestantes) -> cambioFicha(nuevaMatriz(N,M), Rotacion, RamasRestantes).

rotacionesValidasAux(true, _, T) -> rotacionesValidas(T);
rotacionesValidasAux(false, M1, T) -> [M1|rotacionesValidas(T)].

matricesIgualesAux(M1,M2) -> mismoLargoAncho(ancho(M1),ancho(M2),alto(M1),alto(M2), M1, M2).

mismoLargoAncho(A,A,L,L, M1, M2) -> matricesIguales(M1,M2);
mismoLargoAncho(_,_,_,_,_,_) -> false.

matricesIguales([],[]) -> true; 
matricesIguales([H1|[]],[H2|[]])-> filasIguales(H1,H2);
matricesIguales(M1,M2)-> matricesIgualesAux( filasIguales(erlang:hd(M1),erlang:hd(M2)) , erlang:tl(M1), erlang:tl(M2) ).

matricesIgualesAux(true, M1, M2) -> matricesIguales(M1,M2);
matricesIgualesAux(false, _, _) -> false.

filasIguales([],[])->true;
filasIguales([A|T1],[A|T2])-> filasIguales(T1,T2);
filasIguales(_,_)->false.

cambioFicha(Matriz, Rotacion, RamasRestantes) -> rotacionesFicha(ancho(Matriz)-1,alto(Matriz)-1,Matriz,Rotacion, RamasRestantes, 0, 0). %% VALIDA TODA LA COSA

rotacionesFicha(X, Y, Matriz, Rotacion, RamasRestantes, X, Y) -> rotacionesFichaAux(cumple(Matriz,Rotacion,X,Y),Matriz,Rotacion,RamasRestantes,X,Y) ++ [];
rotacionesFicha(X, Ymax, Matriz, Rotacion, RamasRestantes, X, Y) -> rotacionesFichaAux(cumple(Matriz,Rotacion,X,Y),Matriz,Rotacion,RamasRestantes,X,Y) ++ rotacionesFicha(X, Ymax, Matriz, Rotacion, RamasRestantes, 0, Y+1);
rotacionesFicha(Xmax, Ymax, Matriz, Rotacion, RamasRestantes, X, Y) -> rotacionesFichaAux(cumple(Matriz,Rotacion,X,Y),Matriz,Rotacion,RamasRestantes,X,Y) ++ rotacionesFicha(Xmax, Ymax, Matriz, Rotacion, RamasRestantes, X+1, Y).

cumple(M,Rotacion,X,Y) -> cumpleAux(calzaMatriz(M,Rotacion,X,Y), encaja(recMatriz(M, X, Y, X + ancho(Rotacion) -1, Y + alto(Rotacion) -1), Rotacion)). 

cumpleAux(true,true) -> true;
cumpleAux(_,_) -> false.

rotacionesFichaAux(false,_,_,_,_,_) -> [];
rotacionesFichaAux(true,Matriz,Rotacion,RamasRestantes,X,Y) -> [{ubicarSolucion(Matriz,Rotacion,X,Y),RamasRestantes}].

vaciarPila({M,_}) -> vaciarPilaAux(M).

vaciarPilaAux([]) -> true;
vaciarPilaAux([H|M]) -> vaciarPilaAux_fila(vaciarPilaAux_columna(H), erlang:tl(M)).

vaciarPilaAux_fila(false,_) -> false;
vaciarPilaAux_fila(true, []) -> true;
vaciarPilaAux_fila(true, [H|M]) -> vaciarPilaAux_fila(vaciarPilaAux_columna(H),M).

vaciarPilaAux_columna([]) -> true;
vaciarPilaAux_columna([0|_]) -> false;
vaciarPilaAux_columna([_|T]) -> vaciarPilaAux_columna(T).



%%----  ██╗     ██╗███████╗████████╗ █████╗ ███████╗
%%----  ██║     ██║██╔════╝╚══██╔══╝██╔══██╗██╔════╝
%%----  ██║     ██║███████╗   ██║   ███████║███████╗
%%----  ██║     ██║╚════██║   ██║   ██╔══██║╚════██║
%%----  ███████╗██║███████║   ██║   ██║  ██║███████║
%%----  ╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
%%----                                              


spl_lista([])-> [];
spl_lista([[_X,_Y,_,_,_]|T])-> [generaPieza(T)|spl_lista(erlang:tl(T))];
spl_lista([_M|T])-> spl_lista(T).

parsear([],_)-> [];
parsear([H|T],C)-> [sustituirAux(H,C)|parsear(T,C+1)].

sustituirAux([],_)->[];
sustituirAux([H|T],C)-> [sustituirFila(H,C)|sustituirAux(T,C)].

sustituirFila([],_)->[];
sustituirFila([0|T],C)->[0|sustituirFila(T,C)];
sustituirFila([_|T],C)->[C|sustituirFila(T,C)].



%%----  ███╗   ███╗ █████╗ ████████╗██████╗ ██╗███████╗
%%----  ████╗ ████║██╔══██╗╚══██╔══╝██╔══██╗██║╚══███╔╝
%%----  ██╔████╔██║███████║   ██║   ██████╔╝██║  ███╔╝ 
%%----  ██║╚██╔╝██║██╔══██║   ██║   ██╔══██╗██║ ███╔╝  
%%----  ██║ ╚═╝ ██║██║  ██║   ██║   ██║  ██║██║███████╗
%%----  ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝
%%----                                                 

encaja(M,F) -> encajaAux( valDim(ancho(M),ancho(F),alto(M),alto(F)), M, F).
	
encajaAux(true,M,F) -> val_Filas(erlang:hd(M), erlang:hd(F), erlang:tl(M), erlang:tl(F));
encajaAux(false,_,_) -> false.

% Valida las dimensiones de las matrices
valDim(0,0,0,0) -> false;
valDim(A,A,L,L) -> true;
valDim(_,_,_,_) -> false.

val_Filas([],[],[],[]) -> true;
val_Filas(Mf,Ff,[],[]) -> val_Columnas(erlang:hd(Mf), erlang:hd(Ff), erlang:tl(Mf), erlang:tl(Ff));
val_Filas(Mf,Ff,M,F) -> val_FilasAux(val_Columnas(erlang:hd(Mf), erlang:hd(Ff), erlang:tl(Mf), erlang:tl(Ff)), M, F).

val_FilasAux(true,M,F) -> val_Filas(erlang:hd(M), erlang:hd(F), erlang:tl(M), erlang:tl(F));
val_FilasAux(false,_,_) -> false.

val_Columnas(0,0,[],[]) -> true;
val_Columnas(0,_,[],[]) -> true;
val_Columnas(_,0,[],[]) -> true;
val_Columnas(0,0,Mf,Ff) -> val_Columnas(erlang:hd(Mf), erlang:hd(Ff), erlang:tl(Mf), erlang:tl(Ff));
val_Columnas(0,_,Mf,Ff) -> val_Columnas(erlang:hd(Mf), erlang:hd(Ff), erlang:tl(Mf), erlang:tl(Ff));
val_Columnas(_,0,Mf,Ff) -> val_Columnas(erlang:hd(Mf), erlang:hd(Ff), erlang:tl(Mf), erlang:tl(Ff));
val_Columnas(_,_,_,_) -> false.

recMatriz(M,X1,Y1,X2,Y2) -> recortarColumnas(recortarFilas(M,Y1,Y2+1),X1,X2).

recortarFilas(M,Y1,Y2) -> lists:nthtail(Y1, lists:sublist(M, Y2)). 

recortarColumnas([],_,_)->[];
recortarColumnas([H|T],X1,X2)-> [  lists:sublist( lists:nthtail(X1,H), X2-X1+1 )  | recortarColumnas(T,X1,X2)]. 

calzaMatriz(M,F,X,Y) -> calzaMatrizAux(encajaAncho(M,F,X),encajaLargo(M,F,Y)). 

ancho(M) -> erlang:length(erlang:hd(M)).
alto(M) -> erlang:length(M).
encajaAncho(M,F,X) -> encajaAltoLargo(ancho(M),ancho(F),X).
encajaLargo(M,F,Y) -> encajaAltoLargo(alto(M),alto(F),Y).
encajaAltoLargo(AM,AF,XY) when (AM-XY) < AF -> false;
encajaAltoLargo(_,_,_) -> true.
calzaMatrizAux(A,L) when A == true, L == true -> true;
calzaMatrizAux(_,_) -> false.

nuevaMatriz(0,_) -> [];

nuevaMatriz(M,N) -> [nuevaLista(N)|nuevaMatriz(M-1,N)].
nuevaLista(0) -> [];
nuevaLista(N) -> [0|nuevaLista(N-1)].

generaPieza([[]|_T])-> [];
generaPieza([])->[];
generaPieza([H|T])-> [H|generaPieza(T)].

%%----   █████╗ ██████╗  ██████╗██╗  ██╗██╗██╗   ██╗ ██████╗ ███████╗
%%----  ██╔══██╗██╔══██╗██╔════╝██║  ██║██║██║   ██║██╔═══██╗██╔════╝
%%----  ███████║██████╔╝██║     ███████║██║██║   ██║██║   ██║███████╗
%%----  ██╔══██║██╔══██╗██║     ██╔══██║██║╚██╗ ██╔╝██║   ██║╚════██║
%%----  ██║  ██║██║  ██║╚██████╗██║  ██║██║ ╚████╔╝ ╚██████╔╝███████║
%%----  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═════╝ ╚══════╝
%%----                                                               

lee_linea(Archivo) ->
    {ok, Handler} = file:open(Archivo, [read]),
    try obtLineas(Handler)
      after file:close(Handler)
    end.

obtLineas(Handler) ->
    case io:get_line(Handler, "") of
        eof  -> [];
        Line -> [string:strip(Line,right,$\n) | obtLineas(Handler)]
    end.

leer_Archivo([])-> [];
leer_Archivo([H|T])-> 
	[lists:map(fun(X) -> {Int, _} = string:to_integer(X),Int end,string:tokens(H, ","))|leer_Archivo(T)].

%%----  ██████╗ ██╗██╗      █████╗ 
%%----  ██╔══██╗██║██║     ██╔══██╗
%%----  ██████╔╝██║██║     ███████║
%%----  ██╔═══╝ ██║██║     ██╔══██║
%%----  ██║     ██║███████╗██║  ██║
%%----  ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
%%----                             

nueva_pila()->{elem, []}.

push({elem, Nuevo},X)->{elem,[X|Nuevo]}. %push_aux([X|Nuevo],{elem}).
push_aux({elem, Nuevo}, []) -> {elem, Nuevo};
push_aux({elem, Nuevo}, [H|T]) -> push_aux(
										push({elem, Nuevo},H) , T).

pop({elem, []}) -> erlang:error('Pila vacía');
pop({elem, [H|T]}) -> [ {elem, T} , H].

%%----   █████╗ ██╗   ██╗██╗  ██╗██╗██╗     ██╗ █████╗ ██████╗ ███████╗███████╗
%%----  ██╔══██╗██║   ██║╚██╗██╔╝██║██║     ██║██╔══██╗██╔══██╗██╔════╝██╔════╝
%%----  ███████║██║   ██║ ╚███╔╝ ██║██║     ██║███████║██████╔╝█████╗  ███████╗
%%----  ██╔══██║██║   ██║ ██╔██╗ ██║██║     ██║██╔══██║██╔══██╗██╔══╝  ╚════██║
%%----  ██║  ██║╚██████╔╝██╔╝ ██╗██║███████╗██║██║  ██║██║  ██║███████╗███████║
%%----  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝
%%---- 

trans([[]|_]) -> [];
trans(M) -> [lists:map(fun hd/1, M) | trans(lists:map(fun tl/1, M))].

inv([])-> [];
inv(M)-> [H|T] = M,
	[lists:reverse(H)| inv(T)].

flatten([]) -> [];
flatten([H|T]) -> H ++ flatten(T).

%%----  ██████╗  ██████╗ ████████╗ █████╗  ██████╗██╗ ██████╗ ███╗   ██╗███████╗███████╗
%%----  ██╔══██╗██╔═══██╗╚══██╔══╝██╔══██╗██╔════╝██║██╔═══██╗████╗  ██║██╔════╝██╔════╝
%%----  ██████╔╝██║   ██║   ██║   ███████║██║     ██║██║   ██║██╔██╗ ██║█████╗  ███████╗
%%----  ██╔══██╗██║   ██║   ██║   ██╔══██║██║     ██║██║   ██║██║╚██╗██║██╔══╝  ╚════██║
%%----  ██║  ██║╚██████╔╝   ██║   ██║  ██║╚██████╗██║╚██████╔╝██║ ╚████║███████╗███████║
%%----  ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝
%%----                             

hijosRaiz(F) -> [F,hijo1(F),hijo2(F),hijo3(F),hijo4(F),hijo5(F),hijo6(F),hijo7(F)].

hijo1(Pieza) -> trans(Pieza).
hijo2(Pieza) -> inv(Pieza).
hijo3(Pieza) -> inv(hijo1(Pieza)).
hijo4(Pieza) -> trans(hijo3(Pieza)).
hijo5(Pieza) -> trans(hijo2(Pieza)).
hijo6(Pieza) -> inv(hijo4(Pieza)).
hijo7(Pieza) -> inv(hijo5(Pieza)).