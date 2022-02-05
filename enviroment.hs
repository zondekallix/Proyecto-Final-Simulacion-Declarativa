module Enviroment
(
    Enviroment(..),
    InitialData(..),
    boardGeneration,
    createCorralDefault,
    fillUnitType,
    fillUnitByPairList,
    pipeEnviroment,
    updateEnviroment,
    dir_x,
    dir_y,
    moveRobot,
    packEnviroment,
    joinEnviromentList,
    joinEnviromentFull,
    packUnitToPackString,
    fixStringOutput,
    moveChildEnv,
    selectRandomGrid,
    generateGridAround,
    arround_dir,
    generateDirtyFromGrid,
    amountOfDirtyByChild,
    printList,
    dirtyAmount,
    winCondition,
    loseCondition,
    generateEnviroment,
    distributeRobots,
    setRobotsOptions

)
where

import UnitClass
import RandomUtils
import Utils
import Data.List
import System.Random

data Enviroment = Enviroment {
    nSize::Int,
    mSize::Int,
    boardList_env::[(Int,Int)],
    emptyList_env::[Unit],
    obstacleList_env::[Unit],
    dirtyList_env::[Unit],
    childList_env::[Unit],
    robotList_env::[Unit],
    corralList_env::[Unit]
}deriving Show

data InitialData = InitialData {
    nCount::Int,
    mCount::Int,
    childCount::Int,
    obstacleCount::Int,
    dirtyCount::Int,
    robotCount::Int,
    robotTypeIn::Int
}deriving Show

--Direcciones alrededro de una casilla, cada direccion se puede referir a la posicion del numpad respecto el numero 5
arround_dir::Int->(Int,Int)
arround_dir i
    |i== 1 = ((-1),1)
    |i== 2 = (0,1)
    |i== 3 = (1,1)
    |i== 4 = ((-1),0)
    |i== 5 = (0,0)
    |i== 6 = (1,0)
    |i== 7 = (-1,(-1))
    |i== 8 = (0,(-1))
    |i== 9 = (1,(-1))


--direcciones
-- 0 = arriba
-- 1 = derecha
-- 2 = abajo
-- 3 = izquierda
dir_x::Int -> Int
dir_x dir
    |dir == 0 = -1
    |dir == 1 = 0
    |dir == 2 = 1
    |dir == 3 = 0
dir_y::Int-> Int
dir_y dir
    |dir == 0 = 0
    |dir == 1 = 1
    |dir == 2 = 0
    |dir == 3 = -1

-- devuelve una direccion aleatoria en base a un generador
getDirR :: StdGen -> (Int,StdGen)
getDirR g = (dir,newGen) where (dir,newGen) = (randomR (0,7) g)
                

-- ==================Relacionado con Ambiente==========================

--Genera el Ambiente a partir de n y m
boardGeneration::Int->Int->[(Int,Int)]
boardGeneration n m = rectangleBuild n m

--Devuelve True si la posicion esta dentro del ambiente
isInsideEnviroment:: (Int,Int) -> Enviroment -> Bool
isInsideEnviroment (x,y) env = (x < nSize env) && (y < mSize env)
    
--Dado un tipo, una cantidad y un listado de casillas vacias crea un listado de Unidades de tipo type_name de forma aleatoria en esas posiciones 
fillUnitType:: StdGen->String->Int->[(Int,Int)] -> [Unit]
fillUnitType g type_name amount emptyList = fillUnitByPairList cellsToFill type_name
    where cellsToFill = selectRandomFromList g amount emptyList
    
--Dado un listado de posiciones Crea un listado de unidades de tipo type_name en esas posiciones
fillUnitByPairList::[(Int,Int)] -> String -> [Unit]
fillUnitByPairList [] _ = []
fillUnitByPairList (x:xs) type_name = (Unit (fst x) (snd x) type_name): (fillUnitByPairList xs type_name)

-- ===================Relacionado con el Corral===========================
--Crea el corral a partir de la cantidad de niños y el tamaño del ambiente
createCorralDefault:: Int -> Int -> Int -> [Unit]
createCorralDefault amountC n m = fillUnitByPairList pairList "Corral"
    where pairList = take amountC (rectangleBuild n m)

-- ===================Relacionado con Niño===================
--Devuelve True si el niño puede moverse en una dirección especifica y un Int que representa la razón de porque se pudo mover
canMoveChild::Enviroment-> Int->Unit->(Bool,Int)
canMoveChild env dir current_child 
    |elem (x,y) (getPosList corralL) = (False,0)
    |elem (x,y) (getPosList robotL) && (robotState == "2") = (False,0)
    |elem posToMoveChild (getPosList emptyL) = (True,1)
    |elem posToMoveChild (getPosList obstacleL) = if canMoveObstacles env dir current_child then (True,2) else (False,0)
    |otherwise = (False,0)
    where x = xPos current_child
          y = yPos current_child
          xdir = dir_x dir
          ydir = dir_y dir
          posToMoveChild = ((x+xdir),(y+ydir))
          emptyL = emptyList_env env
          obstacleL = obstacleList_env env
          corralL = corralList_env env
          robotL = robotList_env env
          current_robot = getRobotFromList robotL (x,y)
          robotState = getRobotState current_robot

--Devuelve una direccion aleatoria: entre 1,2,3 y 4
choseRandomDir::StdGen->Int
choseRandomDir g= randomNumb g 0 5

getRobotFromList::[Unit]->(Int,Int)->Unit
getRobotFromList [] _ = (Unit (-1) (-1) "Robot_0")
getRobotFromList robotList@(rob:robs) (search_x, search_y)
    |x == search_x && y == search_y = rob
    |otherwise = getRobotFromList robs (search_x,search_y)
    where x = xPos rob
          y = yPos rob
-- ===============Relacionado con Obstaculos==========================

-- Devuelve True si el obstaculo se puede mover por un niño
canMoveObstacles::Enviroment -> Int -> Unit -> Bool
canMoveObstacles env dir (Unit x y _) = 
    let
        lastObst = lastObstacle (obstacleList_env env) x y dir
        current_x = xPos lastObst
        current_y = yPos lastObst
        new_x = current_x + (dir_x dir)
        new_y = current_y + (dir_y dir)
    in elem (Unit new_x new_y "-") (emptyList_env env)


--Mueve los obstaculos en una direccion seleccionada y actualiza el enviroment
-- moveObstacles::Enviroment -> Int -> Int -> Int -> Enviroment
-- moveObstacles env = moveObstaclesAux 

lastObstacle::[Unit]->Int->Int->Int->Unit
lastObstacle obstacleList x_current y_current dir
    |elem new_location (getPosList obstacleList) = lastObstacle obstacleList new_x new_y dir
    |otherwise = (Unit (x_current) (y_current) "Obstaculo")
    where xdir = dir_x dir
          ydir = dir_y dir
          new_x = (x_current+xdir)
          new_y = (y_current+ydir)
          new_location = (new_x,new_y)

--Transforma el Enviroment en una table de listas de String que se utiliza para pintarla en consola
pipeEnviroment::Enviroment->[[String]]
pipeEnviroment env =
    let 
        nLen = nSize env
        mLen = mSize env
        unitList = quicksort(joinEnviromentList env)
        packedList = packEnviroment unitList nLen 0
        packedStrings = packUnitToPackString packedList
        tableString = fixStringOutput packedStrings nLen mLen
    in tableString

--Empaqueta todos los listados del Enviroment
joinEnviromentList:: Enviroment -> [Unit]
joinEnviromentList (Enviroment _ _ _ e o d c r corral) = e++o++d++c++r++corral
--Empaqueta todos los listados del Enviroment menos empty
joinEnviromentFull:: Enviroment -> [Unit]
joinEnviromentFull (Enviroment _ _ _ _ o d c r corral) = o++d++c++r++corral
--Toma la 1ra letra de un string (como string)
symbolOf::String->String
symbolOf (x:xs) = show x
--Convierte el listado plano de objetos de Enviroment y lo transforma en un listado de listas de objetos del enviroment
--De esta forma tenemos una representacion matricial del enviroment
packEnviroment::[Unit]-> Int -> Int ->[[Unit]]
packEnviroment unitList n i
    |i == n = []
    |otherwise = let 
            headList = filter (\u->xPos u == i) unitList
            restList = drop (length headList) unitList
        in headList:packEnviroment restList n (i+1)

--Convierte la matriz de Unidades del Enviroment en una matriz de Strings
packUnitToPackString::[[Unit]]->[[String]]
packUnitToPackString [] = []
packUnitToPackString (x:xs) = let 
    headStr = turnUnitListString x 0
    in headStr:packUnitToPackString xs

--Convierte un listado de Unidades en un listado de String, si dos unidades tienen la misma posicion pertenecen al mismo string
turnUnitListString::[Unit]->Int ->[String]
turnUnitListString [] _ = []
turnUnitListString unit@(u:us) i
    |i /= yPos u = turnUnitListString us i
    |otherwise =
    let
        indexPos = yPos u
        unitSamePos = (filter (\x -> yPos x == indexPos) unit)
        slotStr = [head (unit_type x)| x<-unitSamePos]
        tail = drop (length slotStr) unit
    in slotStr:turnUnitListString us (i+1)

--Arregla el string de salida para que se muestre correctamente en consola y agrega una fila cabecera que representa el numero de la columna
fixStringOutput::[[String]]->Int->Int->[[String]]
fixStringOutput inString n m =
    let 
        columns = map (show) (generateList_0_to_N m)
        fixedHead = map fixChar ("-":columns)
    in fixedHead:(fixStringColumn inString 0)

--Agrega una columna al inicio de cada elemento de la matriz de Unidades de Enviroment que representa la columna
fixStringColumn::[[String]]->Int->[[String]]
fixStringColumn [] _ = []
fixStringColumn (x:xs) i = let 
    fixedHead = map fixChar((show i):x)
   in fixedHead:fixStringColumn xs (i+1)

--Arregla el string de entrada para que coincida con la salida de la consola
fixChar::String->String
fixChar s
    |length s == 0 = " - "
    |length s == 1 = " "++s++" "
    |length s == 2 = s ++ " "
    |otherwise = s


--Listado con las 9 posiciones que puede tener un niño en un grid3x3
grid::[(Int,Int)]
grid = [(1,1),(1,0),(1,-1),(0,1),(0,0),(0,-1),(-1,1),(-1,0),(-1,-1)]





--Realiza los cambios en el ambiente dada t unidades de tiempo
-- recibe un generador, un ambiente ambiente y devuelve como queda el ambiente después de realizar el cambio al mover todos los niños
updateEnviroment :: StdGen -> Enviroment -> Int -> Enviroment
updateEnviroment g env i = new_env
    where
        new_env = if (i >= length (childList_env env))
        then 
            env
        else
            let 
                childL = childList_env env 
                obstacleL = obstacleList_env env
                dirtL = dirtyList_env env
                emptyL = emptyList_env env 
                
                current_child = (childL)!!i
                i' = i+1
                
                (dir,newGen) = randomR(0,3::Int) g
                xdir = dir_x dir
                ydir = dir_y dir
                current_x = xPos current_child
                current_y = yPos current_child
                new_x = current_x + xdir
                new_y = current_y + ydir
                n = nSize env
                m = mSize env

                (garb',g') = randomR (0,8::Int) g
                

                (canMakeMove,typeMove) = canMoveChild env dir current_child
                (newChildList1,newObstacleList1,newEmptyList1) = if typeMove == 1 then moveChild env current_child (new_x,new_y) else (childL,obstacleL,emptyL)
                (newChildList2,newObstacleList2,newEmptyList2) = if typeMove == 2  then moveChildAndObstacles env current_child dir else (childL,obstacleL,emptyL)

                env'
                    |typeMove == 1 = Enviroment n m (boardList_env env) newEmptyList1 newObstacleList1 (dirtyList_env env) newChildList1 (robotList_env env) (corralList_env env)
                    |typeMove == 2 = Enviroment n m (boardList_env env) newEmptyList2 newObstacleList2 (dirtyList_env env) newChildList2 (robotList_env env) (corralList_env env)
                    |otherwise = env

                selectedGrid = selectRandomGrid g' env' current_child 
                (gar,g'') = randomR (0,9::Int) g'
                env''  = generateDirtyFromGrid g'' env' selectedGrid 
                -- env'' = env'

                env''' 
                    |typeMove == 1 = env''
                    |typeMove == 2 = env''
                    |otherwise = env
                

            in updateEnviroment g'' env''' (i+1)


--Mueve el niño a la casilla vacia seleccionada y devuelve un enviroment con las 3 listas que se devuelven en moveChild modificadas 
moveChildEnv::Enviroment->Unit->(Int,Int)->Enviroment
moveChildEnv env@(Enviroment n m board e o d c r corral) current_child@(Unit x y _) (new_x,new_y) =
    let 
        (newChildList,obstacleList,newEmptyList) = moveChild env current_child (new_x,new_y)
    in Enviroment n m board newEmptyList o d newChildList r corral

--Dado un Enviroment, una unidad que deseo mover y una posicion del tablero, mueve dicha unidad a esa posicion y devuelve 3 listas:
--child,obstacle,empty, con los cambios realizados sobre estas al mover al niño
moveChild::Enviroment->Unit->(Int,Int)->([Unit],[Unit],[Unit])
moveChild env@(Enviroment n m board e o d c r corral) current_child (new_x,new_y) = 
    let
        childList = childList_env env
        emptyList = emptyList_env env
        obstacleList = obstacleList_env env
        
        current_x = xPos current_child
        current_y = yPos current_child

        new_child = (Unit new_x new_y "Niño")
        new_empty = (Unit current_x current_y "-")

        oldEnviromentBoard = joinEnviromentFull env
        noEmpty = length ( filter (\x->x==(current_x, current_y)) (getPosList oldEnviromentBoard) ) /= 1
        current_empty = (Unit new_x new_y "-")
        newChildList = new_child:(remove current_child childList)
        newEmptyList' = remove current_empty emptyList
        newEmptyList = if noEmpty  then newEmptyList' else newEmptyList'++[new_empty]

    in (newChildList,obstacleList,newEmptyList)

--Mueve el niño a la casilla con obstaculo seleccionada y devuelve como quedan 3 listas del enviroment modificadas 
--A diferencia del metodo de arriba este se llama cuando el niño se desea mover a la direccion de un obstaculo y se da la entrada como una direccion
--En vez de como una posicion
moveChildAndObstacles::Enviroment->Unit->Int->([Unit],[Unit],[Unit])
moveChildAndObstacles env@(Enviroment n m board e o d c r corral) current_child dir =
    let 
        childList = childList_env env
        emptyList = emptyList_env env
        obstacleList = obstacleList_env env 

        current_x = xPos current_child
        current_y = yPos current_child
        new_x = current_x + dir_x dir 
        new_y = current_y + dir_y dir

        current_obstacle = (Unit new_x new_y "Obstaculo") 
        lastObst = lastObstacle obstacleList current_x current_y dir

        new_obstacle_x = (xPos lastObst) + (dir_x dir)
        new_obstacle_y = (yPos lastObst) + (dir_y dir)

        current_empty = (Unit new_obstacle_x new_obstacle_y "-")


        oldEnviromentBoard = joinEnviromentFull env
        noEmpty = length ( filter (\x->x==(current_x, current_y)) (getPosList oldEnviromentBoard) ) /= 1


        newObstacle = (Unit new_obstacle_x new_obstacle_y "Obstaculo")
        newChild = (Unit new_x new_y "Niño") 
        new_empty = (Unit current_x current_y "-")
        
        newObstacleList = newObstacle:(remove current_obstacle obstacleList)

        newChildList = newChild:(remove current_child childList)
        newEmptyList' = remove current_empty emptyList
        newEmptyList = if noEmpty  then newEmptyList' else newEmptyList'++[new_empty]

    in (newChildList,newObstacleList,newEmptyList)


--Mueve una unidad a la posicion que se solicita y mantiene la consistencia del enviroment al realizarlo
moveRobot::Enviroment->Unit->(Int,Int)->Enviroment
moveRobot env@(Enviroment n m board e o d c r corral) u@(Unit x_current y_current unit_name) (x_new, y_new) = 
    let
        robotList = robotList_env env
        childList = childList_env env

        robotType = getRobotType u
        robotState = getRobotState u
        robot_nameWithChild = "Robot"++robotType++"2"

        new_robotList = if elem (x_new,y_new) (getPosList childList) then (Unit x_new y_new robot_nameWithChild):(remove u robotList)  else (Unit x_new y_new unit_name):(remove u robotList)
        new_emptyList' = remove (Unit x_new y_new "-") (emptyList_env env)

        new_empty = (Unit x_current y_current "-")
        

        oldEnviromentBoard = joinEnviromentFull (Enviroment n m board e d o c new_robotList corral)
        noEmpty = elem (x_current, y_current) (getPosList oldEnviromentBoard) 
        newEmptyList = if noEmpty  then new_emptyList' else new_emptyList'++[new_empty]

    in Enviroment (nSize env) (mSize env) (boardList_env env) newEmptyList (obstacleList_env env) (dirtyList_env env) (childList_env env) new_robotList (corralList_env env)

--Dado un generador, un Enviroment y un niño, devuelve un grid de 3x3 en el que se encuentra el niño, si el grid no se encuentra en el ambiente sera de menor tamaño
selectRandomGrid::StdGen-> Enviroment-> Unit-> [(Int,Int)]
selectRandomGrid g env current_child@(Unit current_x current_y _) =
    let
        m = mSize env
        n = nSize env
        x = current_x
        y = current_y
        around = [arround_dir cell | cell <-[1..9]]
        aroundChild = filter (\tuple -> (fst tuple >= 0) && (snd tuple >= 0) && (fst tuple < n) && (snd tuple < m) )  ([((fst val)+x,(snd val)+y) | val <- around])


    in generateGridAround env ((selectRandomFromList g 1 aroundChild)!!0)
    -- in generateGridAround env (head (selectRandomFromList g 1 aroundChild))

--Dado un enviroment y una posicion central devuelve las casillas que rodean a ee centro
generateGridAround::Enviroment-> (Int,Int)->[(Int,Int)]
generateGridAround env (current_x,current_y) =
    let
        m = mSize env
        n = nSize env
        x = current_x
        y = current_y
        around = [arround_dir cell | cell <-[1..9]]
        listA = [ ( (fst val) + x , (snd val) + y ) | val <- around]
        aroundChild = filter (\tuple -> (fst tuple >= 0) && (snd tuple >= 0) && (fst tuple < n) && (snd tuple < m)) listA
    in listA

--Dado un generador , un enviroment y un grid de 3x3, rellena ese grid con casillas sucias segun la cantidad de niños y actualiza el ambiente
generateDirtyFromGrid::StdGen->Enviroment->[(Int,Int)]->Enviroment
generateDirtyFromGrid g env@(Enviroment n m board e o d c r corral) gridPos =
    let
        emptyList = emptyList_env env
        childList = childList_env env 
        dirtyList = dirtyList_env env
        emptyGridPos = (filter (\x -> elem x (getPosList emptyList) ) gridPos)
        childGridPos = (filter (\x -> elem x (getPosList childList) ) gridPos)
        maxDirty = min(length emptyGridPos) (amountOfDirtyByChild (length childGridPos))
        amountOfDirtyGenerated = randomNumb g 0 (maxDirty)
        (gar,g') = randomR (0,10::Int) g

        fillWithDirtyEmpty = if (length emptyGridPos) == 0  then [] else selectRandomFromList g' amountOfDirtyGenerated emptyGridPos

        newEmptyList = removePosListFromUnit emptyList fillWithDirtyEmpty 
        newDirtyList' = map (generateUnitByPos "Suciedad") (fillWithDirtyEmpty)
        newDirtyList = newDirtyList' ++ dirtyList

    in Enviroment  n m board newEmptyList o newDirtyList childList r corral



--Selecciona la cantidad de suciedad que se va a generar a partir de la cantidad de niños en la grid
amountOfDirtyByChild::Int->Int
amountOfDirtyByChild child_amount
    |child_amount == 1 = 1
    |child_amount == 2 = 3
    |otherwise = 6


--Chequea la condicion de victoria del tablero, un tablero cumple la condicion de victoria si todos los ninos se encuentran en el corral
--O en manos de algun robot
winCondition::Enviroment->Bool
winCondition env = let
    childList = childList_env env
    robotsWithChild = length $ filter (\r -> elem (xPos r,yPos r) (getPosList childList)) (robotList_env env) 
    corralWithChild = length $ filter (\c -> elem (xPos c,yPos c) (getPosList childList)) (corralList_env env)
    childAmount = length (childList_env env)
    in (robotsWithChild + corralWithChild >= childAmount)

--Chequea la condicion de derrota del tanlero, o sea que no se cumplio el objetivo de mantener el tablero al 60%
loseCondition::Enviroment->Bool
loseCondition env = dirtyAmount env > 40 

--Dado una lista de String que se obtiene de un enviroment, pinta en pantalla el enviroment obtenido
printList::[[String]]->IO()
printList [] = return()
printList (x:xs) = do
    print(x)
    printList xs

--Dado un enviroment devuleve el % de suciedad de este
dirtyAmount::Enviroment -> Int
dirtyAmount env = let 
    emptyAmount = length (emptyList_env env)
    -- robotAmount = length (robotList_env env)
    dirtyAmount = length (dirtyList_env env)
    in div (dirtyAmount*100) (emptyAmount + dirtyAmount)

-- cleanAmount::Enviroment -> Int
-- cleanAmount env = 100-(dirtyAmount env)


generateEnviroment::StdGen->InitialData ->Enviroment
generateEnviroment g initData = env
    where 
        n = nCount initData
        m = mCount initData
        child_count = childCount initData
        obstacle_count = obstacleCount initData
        dirty_count = dirtyCount initData
        robot_count = robotCount initData
        robot_type = robotTypeIn initData

    --creando board
        board = boardGeneration n m
        emptyList = fillUnitByPairList board "-"
    --creando posiciones de Corral
        corral = createCorralDefault child_count n m
        emptyList' = removeUnitListFromUnitList emptyList corral
        -- emptyList = emptyList'
    --creando posiciones de Niños

        childs = fillUnitType g "Niño" child_count (getPosList emptyList') 
        emptyList'' = removeUnitListFromUnitList emptyList' childs
        (_,g') = randomR (0,4::Int) g

        -- emptyList = emptyList'
    --creando posiciones de Obstaculos
        obstacles = fillUnitType g'  "Obstaculo" obstacle_count (getPosList emptyList'') 
        emptyList''' = removeUnitListFromUnitList emptyList'' obstacles
        (_,g'') = randomR (0,5::Int) g'
        -- emptyList = emptyList'
    --creando posiciones de Suciedad
        dirty = fillUnitType g'' "Suciedad" dirty_count (getPosList emptyList''') 
        emptyList'''' = removeUnitListFromUnitList emptyList''' dirty
        (_,g''') = randomR (0,6::Int) g''

        -- emptyList = emptyList'
    --creando posiciones de Robots
        robots = fillUnitType g''' "Robot" robot_count (getPosList emptyList'''') 
        emptyList''''' = removeUnitListFromUnitList emptyList'''' robots
        robotsFixed = setRobotsOptions robots robot_type
        -- emptyList = emptyList'

        env = Enviroment{
        nSize = n,
        mSize = m, 
        boardList_env = board,
        emptyList_env = emptyList''''',
        childList_env = childs,
        obstacleList_env = obstacles,
        dirtyList_env = dirty,
        robotList_env = robotsFixed,
        corralList_env = corral
        }

fixRobotType:: Unit -> String -> Unit
fixRobotType rob typeStr = (Unit (xPos rob) (yPos rob) ("Robot"++typeStr++"1"))


--1 Todos niñera
--2 Todos Aspiradora
--3 Todos Mixtos
--4 Todos Random
--5 Mitad y Mitad
setRobotsOptions::[Unit] -> Int -> [Unit]
setRobotsOptions [] _ = []
setRobotsOptions robot_list@(r:rs) typeRobot
    |typeRobot == 2 = (Unit x y "RobotS1"):setRobotsOptions rs typeRobot
    |typeRobot == 3 = (Unit x y "RobotM1"):setRobotsOptions rs typeRobot
    |typeRobot == 4 = (Unit x y "RobotR1"):setRobotsOptions rs typeRobot
    |typeRobot == 5 = distributeRobots robot_list (length robot_list)
    |otherwise = (Unit x y "RobotN1"):setRobotsOptions rs typeRobot
    where
        x = xPos r
        y = yPos r
distributeRobots::[Unit]->Int->[Unit]
distributeRobots [] _ = []
distributeRobots listR@(r:rs) i
    |half = (Unit x y "RobotN1"):distributeRobots rs i
    |otherwise = (Unit x y "RobotS1"):distributeRobots rs i
    where
        x = xPos r
        y = yPos r
        half = ((length listR)-1) >= ( div i 2)