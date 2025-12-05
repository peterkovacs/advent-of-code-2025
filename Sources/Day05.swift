import ArgumentParser
import Foundation
import Parsing

struct Day5: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, ([ClosedRange<Int>], [Int])> {
        Many {
            Parse {
                $0.0...$0.1
            } with: {
                Int.parser()
                "-".utf8
                Int.parser()
            }
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            Whitespace(2, .vertical)
        }

        Many {
            Int.parser()
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            End()
        }      
    }

    func run() throws {
        let (ranges, inventory) = try parsed()
        let part1 = inventory.reduce(into: 0) { partialResult, id in
            partialResult += ranges.contains(where: { $0.contains(id) }) ? 1 : 0
        }

        print("Part 1:", part1)

        let sortedRanges = ranges.sorted { $0.lowerBound == $1.lowerBound ? $0.upperBound < $1.upperBound : $0.lowerBound < $1.lowerBound }

        var range = sortedRanges[0]
        var index = sortedRanges.startIndex + 1
        var count = 0

        while index < sortedRanges.endIndex {
            // Case 1: Disjoint
            if !range.overlaps(sortedRanges[index]) {
                count += range.count
                range = sortedRanges[index]
                index += 1
            }

            // Case 2: Contains
            else if range.contains(sortedRanges[index]) {
                index += 1
            }

            // Case 3: Overlaps
            else {
                assert(range.overlaps(sortedRanges[index]))

                count += (range.lowerBound..<sortedRanges[index].lowerBound).count
                range = sortedRanges[index]
                index += 1
            }
        }

        print("Part 2:", count + range.count)
    }
}