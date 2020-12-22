class Player: CustomStringConvertible {
    final var name: String
    var queue: [Int] = []

    init(name: String, cards: [Int]) {
        queue = cards
        self.name = name
    }

    var description: String {
        return "\(name): \(queue)"
    }

    var out: Bool {
        return queue.isEmpty
    }

    var score: Int {
        var score = 0
        for (i, card) in queue.reversed().enumerated() {
            score += card *  (i + 1)
        }
        return score
    }

    func next() -> Int {
        return queue.remove(at: 0)
    }

    func add(_ card: Int) {
        queue.append(card)
    }
}

func play(p1: Player, p2: Player) -> Player {
    var winner: Player?
    for round in 1... {
        if p1.out {
            winner = p2
            break
        }
        if p2.out {
            winner = p1
            break
        }

        print(" -- Round \(round) -- \n\(p1)\n\(p2)\n")
        let c1 = p1.next(), c2 = p2.next()
        if c1 > c2 {
            p1.add(c1)
            p1.add(c2)
        } else {
            p2.add(c2)
            p2.add(c1)
        }
    }
    print("winner: \(winner!)")
    return winner!
}

var queue: [Int] = [];
while let string = readLine(strippingNewline: true), string != "" {
    if string.starts(with: "Player") {
        continue
    }
    queue.append(Int(string)!)
}
var Player1 = Player(name: "P1", cards: queue)

queue = []
while let string = readLine(strippingNewline: true), string != "" {
    if string.starts(with: "Player") {
        continue
    }
    queue.append(Int(string)!)
}
var Player2 = Player(name: "P2", cards: queue)

let winner = play(p1: Player1, p2: Player2)
print(winner.score)
