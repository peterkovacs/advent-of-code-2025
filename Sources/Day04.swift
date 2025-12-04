import ArgumentParser

struct Day4: ParsableCommand {
    func run() throws {
        let grid = try grid()

        let part1 = grid.indices.reduce(into: 0) { partialResult, coord in 
            if grid[coord] == "@", coord.around.count(where: { grid.isValid($0) && grid[$0] == "@" }) < 4 {
                partialResult += 1
            }
        }

        print("Part 1:", part1)

        var part2 = 0
        var part2Grid = grid 
        while true {
            let removed = part2Grid.remove()
            if removed == 0 {
                break
            }

            part2 += removed
        }

        print("Part 2:", part2)
    }
}

fileprivate extension Grid<Character> {
    mutating func remove() -> Int {
        var copy = self
        var numberRemoved = 0
        for i in self.indices where self[i] == "@" {
            if i.around.count(where: { self.isValid($0) && self[$0] == "@" }) < 4 {
                numberRemoved += 1
                copy[i] = "."
            }
        }

        self = copy
        return numberRemoved
    }
}