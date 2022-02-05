module RobotBehavior
(
    updateRobot,
    moveRobotRandomDir,
    updateRobotNiño,
    robotAction_cleanDirty,
    moveRobotWithChild,
    updateRobot_Aspiradora
)where

import UnitClass
import Enviroment
import BfsRobot
import Utils
import RandomUtils
import System.Random

--Todos los robots del enviroment realizan su accion correspondiente
updateRobot::StdGen -> Enviroment-> Enviroment
updateRobot g env = updateRobot_list g env (robotList_env env)

--Pasa por cada robot del listado de robots del enviroment y va haciendo que realicen sus movimientos uno a uno
updateRobot_list::StdGen -> Enviroment -> [Unit] -> Enviroment
updateRobot_list g env [] = env
updateRobot_list g env@(Enviroment n m b e o d c robotList corral) (r:rs) = 
    let 
        updatedEnvairoment = updateRobot_ByType g env r
        (_,g') = randomR (1,11::Int) g
    in
        updateRobot_list g' updatedEnvairoment rs

--Realiza la accion correspondiente segun el tipo que es el robot
updateRobot_ByType::StdGen -> Enviroment -> Unit -> Enviroment
updateRobot_ByType g env current_robot
    |robot_type == "N" = updateRobotNiño g env current_robot
    |robot_type == "S" = updateRobot_Aspiradora g env current_robot
    |robot_type == "M" = updateRobot_Mixto g env current_robot
    |robot_type == "R" = updateRobot_Random g env current_robot
    |otherwise = []!!(-1) --Provocar un error
    where
        robot_type = getRobotType current_robot

--Mueve un robot encargado de transportar niños
updateRobotNiño::StdGen->Enviroment -> Unit -> Enviroment
updateRobotNiño g env current_robot
        --Acciones según la percepcion
        |robotState == "1" && (availableChild /= [((-1),(-1))]) = moveRobot env current_robot posToMove_RobotToChild
        |robotState == "1" && sameSpotDirty =  robotAction_cleanDirty env current_robot 
        |robotState == "1" && (availableDirty /= [((-1),(-1))]) = moveRobot env current_robot posToMove_RobotToDirty
        -- |robotState == "2" && sameSpotDirty =  robotAction_cleanDirty env current_robot 
        |robotState == "2" && not aboveCorral && sameSpotCorral = robotAction_dropChild env current_robot
        |robotState == "2" && sameSpotCorral && corralEmpty = moveRobotWithChild env current_robot ((x_current-1),(y_current))
        |robotState == "2" && (availableCorral /= [((-1),(-1))]) = moveRobotWithChild env current_robot posToMove_RobotToCorral
        -- |robotState == "2" && (availableDirty /= [((-1),(-1))]) = moveRobotWithChild env current_robot posToMove_RobotToDirty
        |otherwise = moveRobotRandomDir g env current_robot
        -- |otherwise = env
    where
        --Estado del robot
        -- |1 para libre
        -- |2 para cargando al niño
        robotState = getRobotState current_robot
        x_current = xPos current_robot
        y_current = yPos current_robot
        --Percepciones
        --Si hay al menos un niño alcanzable
        availableChild = findBFS env current_robot "Niño"
        posToMove_RobotToChild = head availableChild
        --Si hay al menos una suciedad alcanzable
        availableDirty = findBFS env current_robot "Suciedad"
        posToMove_RobotToDirty = head availableDirty
        --Si hay al menos un corral alcanzable
        
        availableCorral = findBFS env current_robot "Corral"
        amountToMove = take 2 availableCorral
        posToMove_RobotToCorral = if length amountToMove == 1 then head availableCorral else availableCorral!!1
        --Si estoy sobre un niño
        sameSpotChild = elem (Unit x_current y_current "Niño")  (childList_env env)
        --Si estoy sobre una suciedad
        sameSpotDirty = elem (Unit x_current y_current "Suciedad") (dirtyList_env env)
        --Si estoy sobre un corral
        sameSpotCorral = elem (Unit x_current y_current "Corral") (corralList_env env)
        --Si la posicion superior a la mia es un corral
        aboveCorral = elem (Unit (x_current-1) (y_current) "Corral") (corralList_env env) && not (elem (Unit (x_current-1) (y_current) "Niño") (childList_env env))
        --Si el corral de encima está vacio
        corralEmpty = checkEmptyCorral env (x_current-1,y_current)


--Agente Random
updateRobot_Random::StdGen -> Enviroment -> Unit ->Enviroment
updateRobot_Random g env current_robot@(Unit x y robot_name)
    |sameSpotDirty =  robotAction_cleanDirty env current_robot
    |otherwise = moveRobotRandomDir g env current_robot
    where 
        sameSpotDirty = elem (Unit x y "Suciedad") (dirtyList_env env)

--Agente aspiradora
updateRobot_Aspiradora::StdGen -> Enviroment -> Unit ->Enviroment
updateRobot_Aspiradora g env current_robot
        |robotState == "1" && sameSpotDirty =  robotAction_cleanDirty env current_robot 
        |robotState == "1" && (availableDirty /= [((-1),(-1))]) = moveRobot env current_robot posToMove_RobotToDirty
        |robotState == "1" && (availableChild /= [((-1),(-1))]) = moveRobot env current_robot posToMove_RobotToChild

        -- |robotState == "2" && (availableDirty /= [((-1),(-1))]) = moveRobotWithChild env current_robot posToMove_RobotToDirty
        |robotState == "2" && (availableDirty /= [((-1),(-1))]) = robotAction_dropChild env current_robot
        |robotState == "2" && not aboveCorral && sameSpotCorral = robotAction_dropChild env current_robot
        |robotState == "2" && sameSpotCorral && corralEmpty = moveRobotWithChild env current_robot ((x_current-1),(y_current))
        |robotState == "2" && (availableCorral /= [((-1),(-1))]) = moveRobotWithChild env current_robot posToMove_RobotToCorral
        |otherwise = moveRobotRandomDir g env current_robot
    where
        --Estado del robot
        -- |1 para libre
        -- |2 para cargando al niño
        robotState = getRobotState current_robot
        x_current = xPos current_robot
        y_current = yPos current_robot
        --Percepciones
        --Si hay al menos un niño alcanzable
        availableChild = findBFS env current_robot "Niño"
        posToMove_RobotToChild = head availableChild
        --Si hay al menos una suciedad alcanzable
        availableDirty = findBFS env current_robot "Suciedad"
        posToMove_RobotToDirty = head availableDirty
        --Si hay al menos un corral alcanzable
        
        availableCorral = findBFS env current_robot "Corral"
        amountToMove = take 2 availableCorral
        posToMove_RobotToCorral = if length amountToMove == 1 then head availableCorral else availableCorral!!1
        --Si estoy sobre un niño
        sameSpotChild = elem (Unit x_current y_current "Niño")  (childList_env env)
        --Si estoy sobre una suciedad
        sameSpotDirty = elem (Unit x_current y_current "Suciedad") (dirtyList_env env)
        --Si estoy sobre un corral
        sameSpotCorral = elem (Unit x_current y_current "Corral") (corralList_env env)
        --Si la posicion superior a la mia es un corral
        aboveCorral = elem (Unit (x_current-1) (y_current) "Corral") (corralList_env env) && not (elem (Unit (x_current-1) (y_current) "Niño") (childList_env env))
        --Si el corral de encima está vacio
        corralEmpty = checkEmptyCorral env (x_current-1,y_current)

--Agente mixto 
updateRobot_Mixto::StdGen -> Enviroment -> Unit ->Enviroment
updateRobot_Mixto g env current_robot =
        let 
            porCientoDeSuciedad = dirtyAmount env > 25
            condicionBuena = updateRobotNiño g env current_robot
            condicionMala = updateRobot_Aspiradora g env current_robot
        -- in if porCientoDeSuciedad then condicionMala else condicionBuena
        in condicionBuena

--Mueve al robot al niño más cercano
-- robotAction_MoveChild::Enviroment->Unit->(Int,Int)->Enviroment
-- robotAction_MoveChild env current_robot@(Unit x y r_name) =
--     let
--         pathToChild = findBFS enviroment_test current_robot "Niño"
--         canMoveToken = if pathToChild /= [(-1,-1)] then True else False
--         posToMove = head pathToChild

--     in if canMoveToken then moveRobot env current_robot posToMove else env

--Mueve al robot en direccion a la suciedad mas cercana

-- robotAction_MoveDirty::Enviroment->Unit->Enviroment
-- robotAction_MoveDirty env current_robot@(Unit x y r_name) =
--     let
--         pathToDirty = findBFS enviroment_test current_robot "Suciedad"
--         canMoveToken = if pathToDirty /= [(-1,-1)] then True else False
--         posToMove = head pathToDirty

--     in if canMoveToken then moveRobot env current_robot posToMove else env

--Limpia la suciedad del suelo
robotAction_cleanDirty::Enviroment->Unit->Enviroment
robotAction_cleanDirty env@(Enviroment n m b e o d c r corral) u@(Unit x y r_name) = 
    let newDirtyList = remove (Unit x y "Suciedad") d
    in Enviroment n m b e o newDirtyList c r corral

--Suelta al niño que carga el robot
robotAction_dropChild::Enviroment->Unit->Enviroment
robotAction_dropChild env@(Enviroment n m b e o d c r corral) u@(Unit x y r_name) = 
    let
        robotType = getRobotType u
        new_robot = (Unit x y ("Robot"++robotType++"1")) 
        newRobotList = (remove u r)++[new_robot]
    in Enviroment n m b e o d c newRobotList corral

--Mueve al robot en una direccion aleatoria
moveRobotRandomDir:: StdGen-> Enviroment->Unit->Enviroment
moveRobotRandomDir g env robotUnit@(Unit x y r_name) = 
    let
        emptyList = emptyList_env env
        posDirtyList = getPosList (dirtyList_env env)
        posEmptyList = getPosList emptyList
        posibleMove = [(dir_x toMove,dir_y toMove)| toMove<- [0..3], elem ((x + dir_x toMove),(y + dir_y toMove)) posEmptyList || elem ((dir_x toMove),(dir_y toMove)) posDirtyList]
        [(x_ran,y_ran)] = if posibleMove /= [] then (selectRandomFromList g 1 posibleMove) else [(0,0)]
        
        new_env = if (getRobotState robotUnit) == "1" then moveRobot env robotUnit ((x+x_ran), (y+y_ran)) else moveRobotWithChild env robotUnit ((x+x_ran), (y+y_ran))

    in if posibleMove == [] then env else new_env
    
--Revisa si un corral en (x,y) se encuentra vacio
checkEmptyCorral::Enviroment->(Int,Int)->Bool
checkEmptyCorral env (x,y)
    |elem (x,y) (getPosList (robotList_env env)) = False
    |elem (Unit x y "Niño") (childList_env env) = False
    |otherwise = True

--Realiza un movimiento del robot que tiene un niño consigo
moveRobotWithChild::Enviroment->Unit->(Int,Int)->Enviroment
moveRobotWithChild env current_robot@(Unit x y _) (new_x,new_y)=
    let
        env' = moveRobot env current_robot (new_x,new_y)
        env'' = moveChildEnv env' (Unit x y "Niño") (new_x,new_y)
    in env''
--Mueve el robot hacia arriba si puede

-- robotSuciedad
-- robotMixto
-- robotRandom