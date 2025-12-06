import ArgumentParser
import Foundation
import Parsing

struct Day6: ParsingCommand {
    static var `operator`: some Parser<Substring.UTF8View, (initial: Int, op: (Int, Int) -> Int)> {
        OneOf {
            "*".utf8.map { (1, (*) as (Int, Int) -> Int)  }
            "+".utf8.map { (0, (+) as (Int, Int) -> Int)  }
        }
    }

    static var parser: some Parser<Substring.UTF8View, ([[Int]], [(initial: Int, op: (Int, Int) -> Int)])> {
        Many {
            Many {
                Int.parser()
            } separator: {
                Whitespace(.horizontal)
            } terminator: {
                Whitespace(1, .vertical)
            }
        } terminator: {
            Peek { `operator` }
        }

        Many {
            `operator`
        } separator: {
            Whitespace(.horizontal)
        } terminator: {
            Whitespace(.horizontal)
            End()
        }
    }

    static var p2parser: some Parser<Substring.UTF8View, [([Int], (initial: Int, op: (Int, Int) -> Int))]> {
        Many {
            Many {
                Int.parser()
            } separator: {
                Whitespace()
            } terminator: {
                Whitespace(.horizontal)
                Peek { `operator` }
            }

            `operator`
        } separator: {
            Whitespace()
        } terminator: {
            Whitespace(.vertical)
            End()
        }
    }

    func run() throws {
        let (numbers, operations) = try parsed()

        let part1 = numbers[0].indices.reduce(into: 0) { partialResult, i in 
            partialResult += numbers.reduce(into: operations[i].0) { partialResult, inner in 
                partialResult = operations[i].1(partialResult, inner[i])
            }
        }

        print("Part 1:", part1)

        let rotated = try Self.p2parser.parse(try grid().rotated.description)
        let part2 = rotated.reduce(into: 0) { $0 += $1.0.reduce($1.1.initial, $1.1.op)}

        print("Part 2:", part2)
    }
}