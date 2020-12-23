#!/usr/local/share/dotnet/dotnet fsi

let step (lst: list<int32>): list<int32> =
    let curr = lst.Head
    let grab = List.take 3 lst.Tail
    let rest = List.skip 4 lst
    let search = curr :: rest
    let mutable dest = curr
    let mutable destIndex: int32 = -1
    while destIndex = -1 do
        dest <- (if dest = 1
            then (List.length lst) // max value is the length, this is faster
            else dest - 1)
        printfn "looking for %d" dest
        destIndex <- (match List.tryFindIndex (fun n -> n = dest) search with
                        | Some(i) -> i
                        | None -> -1)
    printfn "found dest %d at %d" dest destIndex
    (List.take destIndex rest) @ grab @ (List.skip destIndex rest) @ [curr]

let run (lst: list<int32>) steps =
    let mutable l = lst
    for s = 1 to steps do
        printfn "-- step %d --\n%A" s lst
        l <- step l
    l

printfn "hello"
let arg = fsi.CommandLineArgs.[1]
printfn "solving %s" arg
let lst = Seq.toList (arg.ToCharArray() |> Seq.map (fun (c: char) -> int(sprintf "%c" c)))
printfn "%A" (run lst 100)
