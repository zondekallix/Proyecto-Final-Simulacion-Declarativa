module BfsRobot
(
    findBFS
)
where

import Enviroment
import UnitClass
import Utils
import RandomUtils

--Dado un enviroment, una unidad y en string de busqueda, devuelve la posicion en la que se encuentra la unidad de tipo: <seachString> más cercana
findBFS::Enviroment-> Unit->String-> [(Int,Int)]
findBFS env current_robot searchString = bfsRobot env [current_robot] [(current_robot,current_robot)] searchString current_robotState
    where current_robotState = getRobotState current_robot

--Dado un enviroment, una cola, un listado de casillas visitadas  y el tipo de unidad que estoy buscando, devuelve el camino que se necesita recorrer
-- para encontrar esa unidad
bfsRobot::Enviroment -> [Unit] -> [(Unit,Unit)]->String -> String -> [(Int,Int)]
bfsRobot env queue visited searchString robotState

    |length queue == 0 = [(-1,-1)]
    |unit_type current_node == searchString = checkEndbfs env current_node visited ((-1),(-1))
    |otherwise = 
        let 
            new_queue' = tail queue
            (new_queue,new_visited) = lookAroundAndQueue env current_node new_queue' visited searchString robotState
        in bfsRobot env new_queue new_visited searchString robotState
    where
        current_node = head queue

--Se llama al encontrar una unidad al final del bfs y recorre el camino a la inversa para obtener que camino debo recorrer
checkEndbfs:: Enviroment -> Unit -> [(Unit,Unit)]-> (Int,Int) -> [(Int,Int)]
checkEndbfs env current_node visited (x_old,y_old)
    |parent_node == current_node = []
    -- |((xPos parent_node),(yPos parent_node)) == getPos current_node = []
    |otherwise = (checkEndbfs env parent_node visited (x_current,y_current))++[(x_current,y_current)]
    where
        parent_node = snd (head (filter (\x->fst x == current_node) visited))
        x_current = xPos current_node
        y_current = yPos current_node

--Agrupa todas las posiciones a las que se puede mover una unidad dada en el enviroment
lookAroundAndQueue::Enviroment -> Unit ->[Unit]-> [(Unit,Unit)]-> String -> String -> ([Unit],[(Unit,Unit)])
lookAroundAndQueue env current_node queue visited searchString robotState= 
    let
        x_current = xPos current_node
        y_current = yPos current_node
        dir1 = 0
        dir2 = 1
        dir3 = 2
        dir4 = 3

        childList = childList_env env
        childPosList = getPosList childList

        (available_pos1,new_unit1) = availablePos env current_node dir1 searchString robotState
        -- isChild1 = elem (x_current + dir_x dir1 , y_current + dir_y dir1) childPosList 
        visited1 = elem new_unit1 (map fst visited)

        (available_pos2,new_unit2) = availablePos env current_node dir2 searchString robotState
        -- isChild2 = elem (x_current + dir_x dir2 , y_current + dir_y dir2) childPosList 
        visited2 = elem new_unit2 (map fst visited)

        (available_pos3,new_unit3) = availablePos env current_node dir3 searchString robotState
        -- isChild3 = elem (x_current + dir_x dir3 ,y_current + dir_y dir3) childPosList 
        visited3 = elem new_unit3 (map fst visited)

        (available_pos4,new_unit4) = availablePos env current_node dir4 searchString robotState
        -- isChild4 = elem (x_current + dir_x dir4 , y_current+dir_y dir4) childPosList 
        visited4 = elem new_unit4 (map fst visited)

        toVisit1 = if available_pos1 && not visited1 then [(new_unit1,current_node)] else []
        toVisit2 = if available_pos2 && not visited2 then [(new_unit2,current_node)] else []
        toVisit3 = if available_pos3 && not visited3 then [(new_unit3,current_node)] else []
        toVisit4 = if available_pos4 && not visited4 then [(new_unit4,current_node)] else []

        toQueue1 = map fst toVisit1
        toQueue2 = map fst toVisit2
        toQueue3 = map fst toVisit3
        toQueue4 = map fst toVisit4

        new_queue = queue++toQueue1++toQueue2++toQueue3++toQueue4
        new_visit = visited++toVisit1++toVisit2++toVisit3++toVisit4
    in (new_queue,new_visit)

--Posiciones a las que se puede mover un robot:
--No hay robot en esa posicion
--Es una posicion vacia
--Es una posicion sucia
--Es una posicion con corral sin niño
--Es una posicion con niño que no esta en un corral

availablePos:: Enviroment-> Unit-> Int-> String->String -> (Bool,Unit)
availablePos env (Unit x_current y_current _) dir searchString robotState
    |robotSpot = (False,(Unit (-1) (-1) "ERROR"))
    |emptySpot = (True,emptyUnit)
    |dirtySpot = (True, dirtyUnit)
    |corralSpot && not childSpot = (True, corralUnit)
    -- |robotState == "1" && childSpot && not corralSpot  = (True,childUnit)
    |childSpot && not corralSpot && searchString == "Niño" = (True,childUnit)
    |otherwise = (False,(Unit (-1) (-1) "ERROR"))
    where
        emptyList = emptyList_env env
        dirtyList = dirtyList_env env
        corralList = corralList_env env
        childList = childList_env env
        robotList = robotList_env env
        obstacleList = obstacleList_env env

        x_new = x_current + dir_x dir
        y_new = y_current + dir_y dir
        new_location = (x_new,y_new)

        emptyUnit = (Unit x_new y_new "-")
        emptySpot = elem emptyUnit emptyList

        dirtyUnit = (Unit x_new y_new "Suciedad")
        dirtySpot = elem new_location (getPosList dirtyList)

        corralUnit = (Unit x_new y_new "Corral")
        corralSpot = elem new_location (getPosList corralList)
        
        childUnit = (Unit x_new y_new "Niño")
        childSpot = elem new_location (getPosList childList)

        robotUnit = (Unit x_new y_new "Robot")
        robotSpot = elem new_location (getPosList robotList)
