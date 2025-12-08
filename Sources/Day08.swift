import ArgumentParser
import Collections
import Foundation
import Parsing

struct Day8: ParsingCommand {
    @Argument var input = #file
    @Argument var numberOfConnections = 1000
    static var parser: some Parser<Substring.UTF8View, [Coord3]> {
        Many {
            Parse(Coord3.init) {
                Int.parser()
                ",".utf8
                Int.parser()
                ",".utf8
                Int.parser()
            }
        } separator: {
            Whitespace(.vertical)
        } terminator: {
            End()
        }
    }

    func run() throws {
        let coordinates = try parsed(file: input)

        let closest = coordinates
            .combinations(ofCount: 2)
            .sorted {
                $0[0].distanceSquared(to: $0[1]) < $1[0].distanceSquared(to: $1[1])
            }

        var circuits: [Set<Coord3>] = []

        for pair in closest.prefix(numberOfConnections) {
            let index0 = circuits.firstIndex(where: { $0.contains(pair[0]) })
            let index1 = circuits.firstIndex(where: { $0.contains(pair[1]) })
            switch (index0, index1) {
            case (.some(let a), .some(let b)):
                if a != b {
                    circuits[a].formUnion(circuits[b])
                    circuits.remove(at: b)
                }

            case (.some(let a), .none), (.none, .some(let a)):
                circuits[a].formUnion(pair)

            case (.none, .none):
                circuits.append(Set(pair))
            }
        }

        let part1 = circuits.map(\.count).sorted(by: >).prefix(3).reduce(1, *)
        print("Part 1:", part1)

        for pair in closest.dropFirst(numberOfConnections) {
            let index0 = circuits.firstIndex(where: { $0.contains(pair[0]) })
            let index1 = circuits.firstIndex(where: { $0.contains(pair[1]) })

            switch (index0, index1) {
            case (.some(let a), .some(let b)):
                if a != b {
                    if circuits.count == 2 {
                        print("Part 2:", pair[0].x * pair[1].x)
                        return
                    }
                    circuits[a].formUnion(circuits[b])
                    circuits.remove(at: b)
                }

            case (.some(let a), .none), (.none, .some(let a)):
                circuits[a].formUnion(pair)

            case (.none, .none):
                circuits.append(Set(pair))
            }

        }
    }
}
