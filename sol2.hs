-- `ghci sol.sh` then `main`

module Main (main) where

import Data.Text (splitOn, pack, unpack)
import Data.List
import Data.Maybe
import System.IO

--input = [ 35,20,15,25,47,40,62,55,65,95,102,117,150,182,127,219,299,277,309,576 ]

--goal = 127
goal = 393911906

search :: [Integer] -> [Integer]
search inp = head sums
    where check l = (sum l) == goal
          ts = tails inp
          is = concat [inits l | l <- ts]
          sums = [l | l <- is, check l]

main = do
    h <- openFile "prob.in" ReadMode
    contents <- hGetContents h
    let input = (map (\t -> read t :: Integer) (lines contents))
        res = (search input)
        x = (maximum res)
        n = (minimum res)
    print (n, x, n + x)
