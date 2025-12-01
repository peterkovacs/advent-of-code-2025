import ArgumentParser
import Foundation
import Parsing

struct Day1: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [(Int, Int)]> {
        Parse(input: Substring.UTF8View.self) {
            Many {
                OneOf {
                    Parse { 
                        ($0 / 100, -($0 % 100))
                    } with: { 
                        "L".utf8
                        Int.parser()
                    }
                    Parse {                        
                        ($0 / 100, $0 % 100)
                    } with: {
                        "R".utf8
                        Int.parser()
                    }
                }
            } separator: {
                Whitespace(.vertical)
            } terminator: {
                Whitespace(.vertical)
            }
        }
    }


    func run() throws {
        let numbers = try parsed()         

        let (part1, _) = numbers.reduce(into: (0, 50)) { partialResult, val in
            partialResult.1 += val.1 < 0 ? 100 + val.1 : val.1
            partialResult.1 %= 100

            if partialResult.1 == 0 {
                partialResult.0 += 1
            }
        }

        print("Part 1:", part1)

        let (part2, _) = numbers.reduce(into: (0, 50)) { partialResult, val in 
            let prior = partialResult.1
            partialResult.0 += val.0
            partialResult.1 += val.1

            switch (prior, partialResult.1) {
                case (0..., ..<0): 
                    partialResult.0 += prior > 0 ? 1 : 0
                    partialResult.1 += 100
                case (..<100, 100...):
                    partialResult.0 += prior < 100 ? 1 : 0
                    partialResult.1 -= 100
                case (_, 0): partialResult.0 += 1
                default: break
            }
        }

        print("Part 2:", part2)
    }
}
