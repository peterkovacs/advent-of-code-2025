import ArgumentParser
import Foundation
import Collections

struct Day7: ParsableCommand {
    @Argument var input = #file
    func run() throws {
        let grid = try grid(file: input)
        let position = grid.indices.first { grid[$0] == "S" } ?? .zero

        do {
            var grid = grid
            let part1 = grid.splits(position: position)

            print("Part 1:", part1)
        }

        var memo = [Coord: Int]()
        print("Part 2:", grid.paths(position: position, memo: &memo))
    }
}

fileprivate extension Grid<Character> {
    mutating func splits(position: Coord) -> Int {
        var returnValue = 0
        var queue: Deque<Coord> = [position]

        while var position = queue.popFirst() {
            if self[position] == "|" { continue }

            while isValid(position) && (self[position] == "." || self[position] == "S") {
                (self[position], position) = ("|", position.down)
            }

            if isValid(position) && self[position] == "^" {
                returnValue += 1
                queue.append(position.left)
                queue.append(position.right)
            }
        }

        return returnValue
    }

    func paths(position: Coord, memo: inout [Coord: Int]) -> Int {
        if let returnValue = memo[position] { return returnValue }
        guard isValid(position) else { return 1 }

        switch self[position] {
        case ".", "S":
            let result = paths(position: position.down, memo: &memo)
            memo[position] = result
            return result

        case "^":
            let result = paths(position: position.left, memo: &memo) + paths(position: position.right, memo: &memo)
            memo[position] = result
            return result
            
        default: fatalError()
        }
    }
}
