-- `ghci sol.sh` then `main`

module Main (main) where

import Data.Text (splitOn, pack, unpack)
import Data.List
import Data.Maybe
import System.IO

--input = [ 35,20,15,25,47,40,62,55,65,95,102,117,150,182,127,219,299,277,309,576 ]

plen = 25

taker :: [Integer] -> [[Integer]]
taker l = [take (plen + 1) (drop x l) | x <- [0..(length l - plen - 1)]]

check inp = (l, elemIndex l sums)
    where sums = [x + y | (x:ys) <- tails (take plen inp), y <- ys]
          l = last inp

main = do
    h <- openFile "prob.in" ReadMode
    contents <- hGetContents h
    let input = (map (\t -> read t :: Integer) (lines contents))
    print [x | (x, y) <- (map check (taker (take 1000 input))), isNothing y]
