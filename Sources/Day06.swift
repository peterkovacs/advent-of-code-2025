import ArgumentParser
import Foundation
import Parsing

struct Day6: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, ([[Int]], [(Int, (Int, Int) -> Int)])> {
        Many {
            Many {
                Int.parser()
            } separator: {
                Whitespace(.horizontal)
            } terminator: {
                Whitespace(1, .vertical)
            }
        } terminator: {
            Peek {
                OneOf {
                    "*".utf8
                    "+".utf8
                }
            }
        }

        Many {
            OneOf {
                "*".utf8.map { (1, (*) as (Int, Int) -> Int)  }
                "+".utf8.map { (0, (+) as (Int, Int) -> Int)  }
            }
        } separator: {
            Whitespace(.horizontal)
        } terminator: {
            Whitespace(.horizontal)
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
    }
}