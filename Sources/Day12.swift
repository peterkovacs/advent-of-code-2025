import ArgumentParser
import Foundation
import Parsing

struct Day12: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, ([Grid<Character>], [(Coord, [Int])])> {
        Many(6) {
            Skip { Int.parser() }
            ":".utf8
            Whitespace(1, .vertical)

            Parse {
                Grid($0.joined(), size: .init(x: 3, y: 3))
            } with: {
                Many(3) {
                    From(.substring) { Prefix(3) }
                } separator: {
                    Whitespace(1, .vertical)
                } terminator: {
                    Whitespace(2, .vertical)
                }
            }
        }

        Many {
            Parse(Coord.init) {
                Int.parser()
                "x".utf8
                Int.parser()
            }
            ": ".utf8
            Many {
                Int.parser()
            } separator: {
                Whitespace(.horizontal)
            } terminator: {
                Peek { Whitespace(.vertical) }
            }
        } separator: {
            Whitespace(.vertical)
        } terminator: {
            End()
        }
    }

    func run() throws {
        let (grids, areas) = try parsed()

        let (maybeTooSmall, bigEnough) = areas.partitioned {
            $0.0.x * $0.0.y >= 9 * $0.1.reduce(0, +)
        }
        print("Part 1", bigEnough.count)

        let (check, definitelyTooSmall) = maybeTooSmall.partitioned {
            $0.0.x * $0.0.y < $0.1.enumerated().reduce(into: 0) { $0 += grids[$1.offset].count { $0 == "#" } * $1.element }
        }
    }
}
