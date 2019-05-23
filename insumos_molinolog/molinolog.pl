﻿:- use_module(graficos).

% Este archivo se provee como una guía para facilitar la implementación y 
% entender el uso de graficos.pl
% El contenido de este archivo se puede modificar.

% El predicado minimax_depth/1 define la recursión máxima a utilizar en el algoritmo minimax
minimax_depth(3).

% molinolog(+JugadorNegro,+JugadorBlanco,+T)
% JugadorNegtro y JugadorBlanco pueden ser los átomos humano o maquina.
% T es el tamaño del tablero.
molinolog(JugadorNegro,JugadorBlanco,T) :-
        pce_image_directory(icons),
        gr_crear(Visual, T, [
                     boton('Reiniciar',reiniciar),
                     boton('Salir',salir)] % salir puede ser por el boton o por el click en la ventana
                 ),
    iniciar_juego(Visual,JugadorNegro,JugadorBlanco,T),
    !,
    gr_destruir(Visual).

iniciar_juego(Visual,JugadorNegro,JugadorBlanco,T):-
    gr_dibujar_tablero(Visual,T,[]),
    loop(Visual,negro,JugadorNegro,JugadorBlanco,T,colocar,[]).

contrincante(negro,blanco).
contrincante(blanco,negro).

% --------------------------
% Loop principal
% --------------------------

loop(Visual,Turno,JugadorNegro,JugadorBlanco,T,colocar,PosicionesConFichas) :-
    sformat(Msg, 'Jugador ~w', [Turno]),
    gr_estado(Visual, Msg),
    gr_evento(Visual,E),
    evento(E,Visual,Turno,JugadorNegro,JugadorBlanco,T,colocar,PosicionesConFichas).
    
% TODO fase MOVER
% por ahora solo concidero que es  humano vs humano

hayFicha(Dir,Dist,PosicionesConFichas) :- pertenece((Dir, Dist), PosicionesConFichas).

% pertenece(?X,?L) ← X pertenece a la lista L
pertenece((X,Y,Z),[(X,Y,Z)|_]).
pertenece((X,Y,Z),[_|Ys]) :- pertenece((X,Y,Z),Ys).

% largo(+L,?N) ← N es el largo de la lista L.
largo([],0).
largo([_|Xs],N):- largo(Xs,M),
                  N is M+1.
                  
%hayMolino(Dir,Dist,Turno,PosicionesConFichas) :-

evento(click(Dir,Dist), Visual, Turno, JugadorNegro, JugadorBlanco, T, colocar, PosicionesConFichas) :-
    hayFicha(Dir,Dist,PosicionesConFichas) ->
        ( gr_mensaje(Visual,'La posición no está vacía, no puede colocar una ficha ahí.'),
          loop(Visual,Turno,JugadorNegro,JugadorBlanco,T,colocar,PosicionesConFichas)
        );
        ( largo(PosicionesConFichas,L),
          L < 3 * (T + 1)
        ) ->
        (
          gr_ficha(Visual,T,Dir,Dist,Turno),

          % En este punto ya puso la ficha, ahora hay que chequear si hay molino o no
          % Le paso la posicion nueva porque solo considero molinos que incluyan esa posicion
          % Si se generan 2 molinos a la vez solo se saca una ficha.

          %(hayMolino(Dir,Dist,Turno,PosicionesConFichas) ->
             % Click en la ficha que quiere sacar
             %eliminarFicha(click(Dir,Dist),Turno,Visual,PosicionesConFichas)),
          
          contrincante(Turno,SiguienteTurno),
          loop(Visual,SiguienteTurno,JugadorNegro,JugadorBlanco,T,colocar,[(Dir,Dist,Turno)|PosicionesConFichas])
        );
          gr_mensaje(Visual,'Finalizo la fase colocar, se alcanzó el máximo de fichas para este tablero.'),
          true.
    
evento(salir,Visual,Turno,JugadorNegro,JugadorBlanco,T,colocar,PosicionesConFichas) :-
    (   gr_opciones(Visual, '¿Seguro?', ['Sí', 'No'], 'Sí') ->
            true;
            loop(Visual,Turno,JugadorNegro,JugadorBlanco,T,colocar,PosicionesConFichas)
    ).
        
evento(reiniciar,Visual,Turno,JugadorNegro,JugadorBlanco,T,colocar,PosicionesConFichas) :-
    (   gr_opciones(Visual, '¿Seguro?', ['Sí', 'No'], 'Sí') ->  % reiniciar el juego
           iniciar_juego(Visual,JugadorNegro,JugadorBlanco,T);
           loop(Visual,Turno,JugadorNegro,JugadorBlanco,T,colocar,PosicionesConFichas)
    ).
