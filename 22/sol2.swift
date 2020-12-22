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

    var count: Int {
        return queue.count
    }

    func next() -> Int {
        return queue.remove(at: 0)
    }

    func add(_ card: Int) {
        queue.append(card)
    }

    func copy(head: Int) -> Player {
        return Player(name: name, cards: Array(queue.prefix(head)))
    }
}

var total_rounds = 0
var total_games = 0

func play(p1: Player, p2: Player, game: Int = 1) -> Player {
    total_games += 1
    var winner: Player?
    var c1: Int = 0, c2: Int = 0
    var past_rounds = Set<String>()
    for round in 1... {
        total_rounds += 1
        let round_id = "\(p1)\(p2)"
        if past_rounds.contains(round_id) {
            //print("Repeat \(round_id)")
            winner = p1
            break
        }
        past_rounds.insert(round_id)
        if p1.out {
            winner = p2
            break
        }
        if p2.out {
            winner = p1
            break
        }

        var round_winner: Player
        //print("\n -- Round \(game)/\(round) -- \n\(p1)\n\(p2)")
        c1 = p1.next()
        c2 = p2.next()
        if c1 <= p1.count && c2 <= p2.count {
            //print("subgame!")
            let subwinner = play(p1: p1.copy(head: c1), p2: p2.copy(head: c2), game: game + 1)
            if subwinner.name == p1.name {
                round_winner = p1
            } else {
                round_winner = p2
            }
        } else if c1 > c2 {
            round_winner = p1
        } else {
            round_winner = p2
        }
        if round_winner.name == p1.name {
            p1.add(c1)
            p1.add(c2)
        } else {
            p2.add(c2)
            p2.add(c1)
        }
        //print("round \(game)/\(round) winner: \(round_winner)")
    }
    if let w = winner {
        //print("game \(game) winner: \(w)")
    } else {
        //print("\(game) uhoh no winner")
    }
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
print("DONE: \(winner) with \(winner.score) after \(total_rounds) rounds in \(total_games) games")
