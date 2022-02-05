module RandomUtils
(
    randomList,
    randomNumb,
    selectRandomFromList
)
where

import System.Random
import Data.List
import Utils

--Dado un generador y un intervalo, devuelve un numero de ese intervalo
randomNumb:: StdGen -> Int -> Int->Int
randomNumb g minVal maxVal = 
    let
        realMax = max minVal (maxVal-1)
        x = take 1 (randomRs (minVal,realMax) g ::[Int])
        (a:_) = x 
    in a

--Recibe un generador, un minimo y maximo para un intervalo y la catnidad amount de elementos que se desean tomar
--de ese intervalo y devuelve una lista aleatoria de amount elementos sin repeticion de ese intervalo
--Deprecated , Ineficiente
randomList:: StdGen -> Int -> Int -> Int -> [Int]
randomList g minVal maxVal amount = 
    let
        realMax = max minVal (maxVal-1)
    in take amount (noDuplicate(randomRs (minVal,realMax) g ::[Int]))

--Recibe un generador, la cantidad de elementos que quiero tomar de una lista y una lista y devuelve n elementos tomados al azar de esa lista
--Ineficiente
selectRandomFromListDeprecated::StdGen -> Int->[a] ->[a]
selectRandomFromListDeprecated g n l = 
    let
        idx = randomList g 0 (length l) n 
    in 
        [l!!i | i <- idx, i<length l,i>= 0]

--Dado un generador, una cantidad de elementos que se desean seleccionar de uan lista y una lista, devuelve otra lista con 
--esa cantidad de elementos seleccionados de forma aleatoria
selectRandomFromList::(Eq a) => StdGen -> Int -> [a] -> [a]
selectRandomFromList g n list = take n (selectRandomFromListOptimiced g list)

selectRandomFromListOptimiced::(Eq a)=> StdGen -> [a] -> [a]
selectRandomFromListOptimiced _ [] = []
selectRandomFromListOptimiced g listIn =
    let 
        len = length listIn
        i = randomNumb g 0 len
        (_,g') = randomR (0,20::Int) g
        selectedElem = listIn!!i
        newList = remove selectedElem listIn
    in (selectedElem:(selectRandomFromListOptimiced g' newList))


--Para testing
main = do
    g <- newStdGen
    print(randomList g 1 100 5)
    g <- newStdGen
    print(randomNumb g 1 100)