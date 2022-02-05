module UnitClass
(
    Unit(..),
    getPos,
    getPosList,
    moveUnitByDir,
    moveUnitToDir,
    moveUnitToPos,
    removeUnitListFromUnitList,
    removePosListFromUnit,
    elemRobot,
    getRobotType,
    getRobotState,
    generateUnitByPos
    
)
where

import Utils

--Cada elemento del ambiente(les llamaremos unidad) tiene en común una posicion X, una posicion Y y un tipo(Niño,Obstaculo, Corral, etc)
data Unit = Unit{
                    xPos::Int,
                    yPos::Int,
                    unit_type::String
                } deriving (Show,Eq)

instance Ord Unit where
    (<) (Unit x1 y1 t1) (Unit x2 y2 t2)
        |x1 < x2 = True
        |x1 == x2 = y1 < y2
        |otherwise = False
    (<=)(Unit x1 y1 t1) (Unit x2 y2 t2)
        |x1 < x2 = True
        |x1 == x2 = y1 <= y2
        |otherwise = False
    (>) u1 u2 = not (u1<=u2) 
    (>=) u1 u2 = not (u1<u2)


--Devuelve el tipo de un robot que se le asigno una tarea
--Types
--1 == niñera
--2 == limpiapisos
--3 == niñerLimpia
--4 == aleatorio
getRobotType:: Unit -> String
getRobotType u = [r_type!!5]
    where r_type = unit_type u
--Devuelve el estado de un robot al que se le asigno una tarea
-- Status
-- 1 Libre
-- 2 Cargando niño
getRobotState:: Unit->String
getRobotState u = [r_status!!6]
    where r_status = unit_type u

--Devuelve si un elemento de una lista de Unidades es un Robot, ignorando tipo y estado
elemRobot::Unit-> [Unit]->Bool
elemRobot unt (u:us)
    |isRobot = True
    |otherwise = elemRobot unt us
    where isRobot = (take 5 (unit_type unt)) == "Robot"

--Devuelve la posicion x,y de la unidad en forma de tupla(mas limpieza para operaciones futuras)
getPos:: Unit -> (Int,Int)
getPos u = (xPos u,yPos u)  

getPosList::[Unit]->[(Int,Int)]
getPosList [] = []
getPosList (u:us) = (getPos u):getPosList us 

--Mueve una Unidad a la posicion que se le da de entrada
moveUnitToPos::Unit->Int->Int->Unit
moveUnitToPos (Unit _ _ utype) x y = (Unit x y utype) 

--Mueve la unidad segun la direccion que se le da de entrada
moveUnitToDir::Unit -> Int -> Int -> Unit
moveUnitToDir (Unit xold yold utype) xnew ynew = (Unit (xold+xnew) (yold+ynew) utype) 

--Mueve la unidad segun el tipo de direccion que se le da de entrada
--1 = arriba
--2 = derecha
--3 = abajo
--4 = izquierda
moveUnitByDir::Unit -> Int -> Unit
moveUnitByDir (Unit xold yold utype) dir 
    |dir == 1 = Unit (xold) (yold-1) utype
    |dir == 2 = Unit (xold+1) (yold) utype
    |dir == 3 = Unit (xold-1) (yold) utype
    |dir == 4 = Unit (xold) (yold+1) utype
    |otherwise = Unit (-666) (-666) "ERROR"

--Dado dos listas de Unit elimina de la 1ra lista los Unit que tengan la misma posicion que los que se encuentran en la 2da
removeUnitListFromUnitList::[Unit]->[Unit]->[Unit]
removeUnitListFromUnitList u1 u2 = removePosListFromUnit u1 (getPosList u2)

--Dada una lista de Unidades y una lista de posiciones, remueve todas las unidades que se encuentren en alguna posicionn de la lista de posiciones
removePosListFromUnit::[Unit]->[(Int,Int)]->[Unit]
removePosListFromUnit list [] = list
removePosListFromUnit [] _ = []
removePosListFromUnit unitA unitB = filter (\x ->not( elem (getPos x) unitB )) unitA 

--Dado un nombre de una Unit y una posicion, genera la unidad en esa posicion
generateUnitByPos::String->(Int,Int) ->Unit
generateUnitByPos name (x,y) = (Unit x y name) 