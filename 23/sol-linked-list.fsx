#!/usr/local/share/dotnet/dotnet fsi

// Implements an indexed linked list solution. Each cup is a Link with a pointer to the next cup clockwise. The list is
// circular (the last cup points back to the first).
// We also keep an ordered index of all cups so we can find the one of a given value in O(1) time.
// This allows each step to be a constant-time operation: walk forward from the current link to grab cups; use the index
// to jump to the destination/target cup, with descending value; then re-link the ends of each segment to move the
// grabbed cups.
//
// Usage: sol.fsx INITIAL_VALUES STEPS [MAX_VALUE]
//   Runs STEPS iterations of the cups, from the initial cups as a string.  If MAX_VALUE is provided, cups up to that
//   value are appended to the initial values (for part 2).

type Link(v: int32) =
    member this.value = v
    member val _next: Option<Link> = None with get, set
    member this.next with get(): Link = this._next.Value and set v = this._next <- Some(v)
    override this.ToString(): string = if this.value = 0 then "" else (sprintf "%d (-> %d)" this.value this.next.value)

let arg = fsi.CommandLineArgs.[1]
let steps = int(fsi.CommandLineArgs.[2])
let max = if fsi.CommandLineArgs.Length >= 4 then int(fsi.CommandLineArgs.[3]) else arg.Length

let links = Array.init (max + 1) (fun i -> Link(i))
for i = 1 to max-1 do
    links.[i].next <- links.[i+1]
links.[max].next <- links.[1]

let link (a: Link, b: Link): unit =
    //printfn "connecting %d -> %d" a.value b.value
    a.next <- b

let initialList = Seq.toArray (arg.ToCharArray() |> Seq.map (fun (c: char) -> int(sprintf "%c" c)))
let ll = initialList.Length - 1
for i = 0 to ll do
    let n = if i = ll then 0 else i+1
    link(links.[initialList.[i]], links.[initialList.[n]])

if max > initialList.Length then
    link(links.[initialList.[ll]], links.[ll+2])
    link(links.[max], links.[initialList.[0]])
printfn "%A" links

let collectValues (from: Link): seq<int32> =
    let mutable l = from
    seq {
        yield l.value
        l <- l.next
        while l <> from do
            yield l.value
            l <- l.next
    }

printfn "solving %A (to %d) for %d steps" initialList max steps

let mutable currLink = links.[initialList.[0]]
printfn "after 0 steps: %A" (Seq.toArray (collectValues currLink))

for step = 1 to steps do
    let grabs = [| currLink.next; currLink.next.next; currLink.next.next.next |]
    let mutable targetValue = if currLink.value = 1 then max else (currLink.value - 1)
    while targetValue = grabs.[0].value || targetValue = grabs.[1].value || targetValue = grabs.[2].value do
        targetValue <- if targetValue = 1 then max else (targetValue - 1)
    //
    // ... <-> currLink <-> grabs.[0] <-> grabs.[1] <-> grabs.[2] <-> afterLink <-> ... <-> targetLink <-> ...
    //
    // becomes:
    //
    // ... <-> currLink <-> afterLink <-> ... <-> targetLink <-> grabs.[0] <-> grabs.[1] <-> grabs.[2] <-> ...
    //
    let targetLink = links.[targetValue]
    let targetNext = targetLink.next
    let afterLink = grabs.[2].next
    link(targetLink, grabs.[0])
    link(currLink, afterLink)
    link(grabs.[2], targetNext)
    // proceed to the new next link.
    currLink <- currLink.next
    if step % 1000 = 0 then
        printfn "after %d steps: %A" step (Seq.toArray (collectValues currLink))

printfn "after %d steps: %A" steps (Seq.toArray (collectValues currLink))
let goalLink = links.[1]
printfn "goals: %O %O %O" goalLink goalLink.next goalLink.next.next
