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

    struct Volume {
        var coordinates: Set<Coord3>
        var min: Coord3
        var max: Coord3

        init(coordinates: some Sequence<Coord3>) {
            self.coordinates = Set(coordinates)
            self.min = .init(
                x: coordinates.map(\.x).min() ?? .zero,
                y: coordinates.map(\.y).min() ?? .zero,
                z: coordinates.map(\.z).min() ?? .zero
            )
            self.max = .init(
                x: coordinates.map(\.x).max() ?? .zero,
                y: coordinates.map(\.y).max() ?? .zero,
                z: coordinates.map(\.z).max() ?? .zero
            )
        }

        func contains(_ coord: Coord3) -> Bool {
            coord.x >= min.x &&
            coord.x <= max.x &&
            coord.y >= min.y &&
            coord.y <= max.y &&
            coord.z >= min.z &&
            coord.z <= max.z && coordinates.contains(coord)
        }

        mutating func add(_ coord: Coord3) {
            coordinates.insert(coord)
            min.x = Swift.min(min.x, coord.x)
            min.y = Swift.min(min.y, coord.y)
            min.z = Swift.min(min.z, coord.z)
            max.x = Swift.max(max.x, coord.x)
            max.y = Swift.max(max.y, coord.y)
            max.z = Swift.max(max.z, coord.z)

        }

        mutating func add(_ other: Volume) {
            coordinates.formUnion(other.coordinates)
            min.x = Swift.min(min.x, other.min.x)
            min.y = Swift.min(min.y, other.min.y)
            min.z = Swift.min(min.z, other.min.z)
            max.x = Swift.max(max.x, other.max.x)
            max.y = Swift.max(max.y, other.max.y)
            max.z = Swift.max(max.z, other.max.z)
        }
    }

    struct Pair: Comparable {
        let first: Coord3
        let second: Coord3

        init(_ pair: [Coord3]) {
            self.first = pair[0]
            self.second = pair[1]
        }

        static func < (lhs: Pair, rhs: Pair) -> Bool {
            lhs.first.distanceSquared(to: lhs.second) < rhs.first.distanceSquared(to: rhs.second)
        }
    }

    func run() throws {
        let coordinates = try parsed(file: input)
        var closest = Heap(
            coordinates
                .combinations(ofCount: 2)
                .map(Pair.init)
        )

        var circuits: [Volume] = []

        for _ in 0..<1000 {
            guard let pair = closest.popMin() else { return }
            let index0 = circuits.firstIndex(where: { $0.contains(pair.first) })
            let index1 = circuits.firstIndex(where: { $0.contains(pair.second) })
            switch (index0, index1) {
            case (.some(let a), .some(let b)):
                if a != b {
                    circuits[a].add(circuits[b])
                    circuits.remove(at: b)
                }

            case (.some(let a), .none), (.none, .some(let a)):
                circuits[a].add(pair.first)
                circuits[a].add(pair.second)

            case (.none, .none):
                circuits.append(Volume(coordinates: [pair.first, pair.second]))
            }
        }

        let part1 = circuits.map(\.coordinates.count).sorted(by: >).prefix(3).reduce(1, *)
        print("Part 1:", part1)

        while let pair = closest.popMin() {
            let index0 = circuits.firstIndex(where: { $0.contains(pair.first) })
            let index1 = circuits.firstIndex(where: { $0.contains(pair.second) })

            switch (index0, index1) {
            case (.some(let a), .some(let b)):
                if a != b {
                    if circuits.count == 2 {
                        print("Part 2:", pair.first.x * pair.second.x)
                        return
                    }

                    circuits[a].add(circuits[b])
                    circuits.remove(at: b)
                }

            case (.some(let a), .none), (.none, .some(let a)):
                circuits[a].add(pair.first)
                circuits[a].add(pair.second)

            case (.none, .none):
                circuits.append(Volume(coordinates: [pair.first, pair.second]))
            }

        }
    }
}
