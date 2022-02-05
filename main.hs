import UnitClass
import RandomUtils
import Utils
import System.Random
import Enviroment
import BfsRobot
import RobotBehavior

main :: IO ()
main = do
    putStrLn("Seleccione que tipo de Simulacion desea realizar")
    putStrLn("1-Simulacion detallada unica")
    putStrLn("2-Simulacion multiple segun la entrada y solo mostrar resultados")
    putStrLn("\n")
    simulation_type <- getLine
    putStrLn("\n")
    -- let simulation_type = "2"

    putStrLn ("Rellene los datos a continuacion según el ambiente que desee crear")
    putStrLn ("Largo del ambiente: ")
    nStr <- getLine
    putStrLn("\n")
    -- let nStr = "15"
    putStrLn("Ancho del ambiente: ")
    mStr <- getLine
    putStrLn("\n")
    -- let mStr = "15"

    putStrLn ("Cantidad de niños: ")
    cStr <- getLine
    putStrLn("\n")
    -- let cStr = "20"

    putStrLn ("Cantidad de obstaculos: ")
    oStr <- getLine
    putStrLn("\n")
    -- let oStr = "10"

    putStrLn ("Cantidad de suciedad: ")
    dStr <- getLine
    putStrLn("\n")
    -- let dStr = "20"

    putStrLn ("Cantidad de robots: ")
    rStr <- getLine
    putStrLn("\n")
    -- let rStr = "3" 

    putStrLn ("Tiempo en que demora en cambiar el ambiente:")
    tStr <- getLine
    putStrLn("\n")
    -- let tStr = "3"

    putStrLn ("Ingrese un numero según tipo de robot que desea utilizar")
    putStrLn ("1-Niñera")
    putStrLn ("2-Aspiradora")
    putStrLn ("3-Mixto")
    putStrLn ("4-Random")
    putStrLn ("5-Mitad y Mitad")
    putStrLn("\n")
    r_typeStr <- getLine
    putStrLn("\n")
    -- let r_typeStr = "1" 

    putStrLn("Seleccione cantidad de simulaciones que desea realizar")
    putStrLn("(Solo se utiliza este valor si seleccionó simulaciones multiples)")
    test_amountStr <-getLine
    putStrLn("\n")
    -- let test_amountStr = "1000"

    let n = read nStr::Int
    let m = read mStr::Int
    let child_count = read cStr::Int
    let obstacle_count = read oStr::Int
    let dirty_count = read dStr::Int
    let robot_count = read rStr::Int
    let t = read tStr :: Int
    let simulationOptionSelected = read simulation_type ::Int
    let robot_type = read r_typeStr::Int
    let test_amount = read test_amountStr::Int
    g <- newStdGen

    
    let inputData = InitialData n m child_count obstacle_count dirty_count robot_count robot_type
    let env = generateEnviroment g inputData

    -- print (robotList_env env)
    -- printList (pipeEnviroment env)
    print("===========================")
    let output = if simulationOptionSelected == 1  then singleSimulation g env t else multipleSimulations g env inputData t test_amount
    output
    
    
--Realiza una simulacion y muestra en pantalla lo que sucede paso a paso
singleSimulation::StdGen ->Enviroment->Int->IO()
singleSimulation g env t = do
    print("Starting Single Simulation...")
    print("Enviroment Inicial")
    printList (pipeEnviroment env)
    putStrLn ("Inserte 1 para continuar y 2 para detenerse..."++"\n\n")
    singleSimulationLoop g env t 1

singleSimulationLoop::StdGen -> Enviroment -> Int-> Int -> IO()
singleSimulationLoop g env t i_current = do

    let env' = updateRobot g env
    let (gar,g') = randomR (0,length [1,2,3]) g
    let i' = i_current+1

    putStrLn ("Enviroment "++(show i_current))
    print("Moviendo Robots")
    printList(pipeEnviroment env')
    print("toUpdate = " ++ show (mod i_current t)) 
    putStrLn ("Inserte 1 para continuar y 2 para detenerse..."++"\n\n")
    aux' <- getLine
    let auxStr = read aux'::Int
    let end = if winCondition env'
        then putStrLn("Win Condition Reached") 
        else 
            if loseCondition env'
                then putStrLn("Lose Condition Reached")
                else 
                    if (mod i' t) == 0
                    then checkUpdateEnviroment g' env' t i'
                    else singleSimulationLoop g' env' t i'
                 -- singleSimulationLoop g'' env'' t i'

    let end' = if auxStr == 1 then end else putStrLn("Simulation Stoped with "++ (show (dirtyAmount env))++"% of dirty")
    end'

--Se llama si pasaron t turnos y debo actualizar el ambiente
checkUpdateEnviroment::StdGen-> Enviroment -> Int -> Int -> IO()
checkUpdateEnviroment g env t i_current= do
    let env' = updateEnviroment g env 0
    print("Actualizando ambiente") 
    let (gar,g') = randomR (0,length [1,2,3]) g
    -- print(env')
    putStrLn ("Inserte 1 para continuar y 2 para detenerse..."++"\n\n")
    aux' <- getLine
    let auxStr = read aux'::Int

    let end = if winCondition env'
        then putStrLn("Win Condition Reached") 
        else 
            if loseCondition env'
                then putStrLn("Lose Condition Reached")
                else singleSimulationLoop g' env' t i_current
    let end' = if auxStr == 1 then end else putStrLn("Simulation Stoped with "++ (show (dirtyAmount env))++"% of dirty")
    end'
            




--Realiza multiples simulaciones y muestra los resultados de cada una, si una simulacion no se ha detenido al actualizar el ambiente 100 veces
--esta se detendra y se cosniderara victoriosa

multipleSimulations:: StdGen -> Enviroment->InitialData -> Int -> Int -> IO()
multipleSimulations g env inputData t test_amount = multipleSimulationsLoop g env inputData t 0 test_amount []

multipleSimulationsLoop::StdGen -> Enviroment ->InitialData -> Int -> Int -> Int-> [Int] ->IO()
multipleSimulationsLoop g env initData t actualLoop maxLoop listResults
    |actualLoop >= maxLoop = do
        print("Simulating.... please wait")
        print (show(listResults))
        print("Ended the "++(show maxLoop)++" Simulation: ")
        print("Victory rate is: "++ (show (meanList listResults)) ++ "%" )
    |otherwise = do
        let (result,env') = simulateUntilStop g env t 0
        let (_,g') = randomR (0,1::Int) g
        let new_env = generateEnviroment g' initData
        -- print(robotList_env new_env)
        -- print("========")
        let (_,g'') = randomR (0,2::Int) g'
        let listResults' = ((result*100):listResults)
        multipleSimulationsLoop g'' new_env initData t (actualLoop + 1) maxLoop listResults'
    
simulateUntilStop::StdGen -> Enviroment -> Int -> Int ->(Int,Enviroment)
simulateUntilStop g env t actualLoop 
    |loseCondition env = (0,env)
    |winCondition env = (1,env)
    |actualLoop >= t*100 = (1,env)
    |otherwise = simulateUntilStop g' env' t (actualLoop + 1)
    where
        env' = simulateLoop g env t actualLoop
        (_,g') = randomR (0,3::Int) g

simulateLoop::StdGen -> Enviroment -> Int-> Int ->Enviroment
simulateLoop g env t i_current =
    let 
        shouldUpdate = mod i_current t == 0
        new_env = if shouldUpdate then updateEnviroment g env 0 else updateRobot g env 
    in new_env
