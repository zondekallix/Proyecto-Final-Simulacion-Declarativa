module Utils
(
    noDuplicate,
    generateList_0_to_N,
    generateList_N_to_0,
    rectangleBuild,
    removeListFromList,
    quicksort,
    remove,
    meanList
)
where

--Recibe una lista y devuelve la misma lista sin elementos duplicaods
noDuplicate::(Eq a)=>[a]->[a]
noDuplicate [] = []
noDuplicate (x:xs) = x:noDuplicate (filter ( \y -> x /= y) xs)

--Genera una lista con los elementos desde N hasta 0
generateList_N_to_0:: Int -> [Int]
generateList_N_to_0 0 = []
generateList_N_to_0 n = (n-1):generateList_N_to_0 (n-1)

--Genera una lista con los elementos desde 0 hasta N
generateList_0_to_N::Int -> [Int]
generateList_0_to_N n = reverse (generateList_N_to_0 n)

--Genera las coordenadas de un rectangulo de nxm 
rectangleBuild:: Int -> Int -> [(Int,Int)]
rectangleBuild n m = let rectangle = [(x,y)| x<-generateList_0_to_N n, y<-generateList_0_to_N m] in rectangle

--Elimina los elementos de la 2da lista que se encuentran en la 1ra
removeListFromList::(Ord a)=>[a]->[a]->[a]
removeListFromList [] _ = []
removeListFromList (x:xs) listB
    |elem x listB = removeListFromList xs listB
    |otherwise = x:removeListFromList xs listB

--Ordena una lista de entrada
quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) = quicksort lesser ++ [x] ++ quicksort greater
    where
        lesser  = filter (< x) xs
        greater = filter (>= x) xs

--Elimina todos los elementos u de un listado 
remove::(Eq a)=> a -> [a] -> [a]
remove _ [] = []
remove u (x:xs)
    | u == x = remove u xs
    | otherwise = x:(remove u xs)

--Calcula el promedio de una lista de Enteros
meanList::[Int]->Int
meanList [] = 0
meanList listInput = div (sum listInput) (length listInput)
