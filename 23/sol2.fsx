#!/usr/local/share/dotnet/dotnet fsi

// Usage: sol.fsx INITIAL_VALUES STEPS [MAX_VALUE]
//   Runs STEPS iterations of the cups, from the initial cups as a string.  If MAX_VALUE is provided, cups up to that
//   value are appended to the initial values (for part 2).


let arg = fsi.CommandLineArgs.[1]
let steps = int(fsi.CommandLineArgs.[2])
let max = if fsi.CommandLineArgs.Length >= 4 then int(fsi.CommandLineArgs.[3]) else arg.Length

// The `links` array implements a linked list: the value at each index is the next cup after that index.
// For example, `links.[3]` is the cup after the cup labeled 3.  Index 0 is not used as there is no cup 0.  The links
// wrap around.
// The cup arrangement [4 2 5 1 3] would be represented as this array:
// `[| 0; 3; 5; 4; 2; 1 |]
//
// This setup allows constant-time rearranging, as described below.
let links = Array.init (max + 1) (fun i -> 0)
for i = 1 to max-1 do
    links.[i] <- i+1
links.[max] <- 1

let initialList = Seq.toArray (arg.ToCharArray() |> Seq.map (fun (c: char) -> int(sprintf "%c" c)))
let ll = initialList.Length - 1
for i = 0 to ll do
    let n = if i = ll then 0 else i+1
    links.[initialList.[i]] <- initialList.[n]

if max > initialList.Length then
    links.[initialList.[ll]] <- ll + 2
    links.[max] <- initialList.[0]
printfn "%A" links

let collectValues (from: int32): seq<int32> =
    let mutable v = from
    seq {
        yield v
        v <- links.[v]
        while v <> from do
            yield v
            v <- links.[v]
    }

printfn "solving %A (to %d) for %d steps" initialList max steps

let mutable currVal = initialList.[0]
printfn "after 0 steps: %A" (Seq.toArray (collectValues currVal))

for step = 1 to steps do
    let grabs = [| links.[currVal]; links.[links.[currVal]]; links.[links.[links.[currVal]]] |]
    let mutable targetVal = if currVal = 1 then max else (currVal - 1)
    while targetVal = grabs.[0] || targetVal = grabs.[1] || targetVal = grabs.[2] do
        targetVal <- if targetVal = 1 then max else (targetVal - 1)
    //
    // ... -> currVal -> grabs.[0] -> grabs.[1] -> grabs.[2] -> afterVal -> ... -> targetVal -> targetNext -> ...
    //
    // becomes:
    //
    // ... -> currVal -> afterVal -> ... -> targetVal -> grabs.[0] -> grabs.[1] -> grabs.[2] -> targetNext -> ...
    //
    let targetNext = links.[targetVal]
    let afterVal = links.[grabs.[2]]
    links.[targetVal] <- grabs.[0]
    links.[currVal] <- afterVal
    links.[grabs.[2]] <- targetNext
    // proceed to the new next link.
    currVal <- links.[currVal]
    if step % 100000 = 0 then
        printfn "after %d steps: %A" step (Seq.toArray (collectValues currVal))

printfn "after %d steps: %A" steps (Seq.toArray (collectValues currVal))
let goalLink = 1
printfn "goals: %d %d" links.[goalLink] links.[links.[goalLink]]
