import ArgumentParser
import Atomics
import Foundation
import Parsing

struct Day3: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [[Int]]> {
        Many {
            Many {
                Digits(1...1)
            }
        } separator: {
            Whitespace(1, .vertical)
        } terminator: {
            End()
        }
    }

    func run() throws {
        let batteryBanks = try parsed()

        let part1: ManagedAtomic<Int> = .init(0)
        DispatchQueue.concurrentPerform(iterations: batteryBanks.count) {
            part1.wrappingIncrement(by: batteryBanks[$0][...].battery(length: 2), ordering: .relaxed)
        }
        print("Part 1:", part1.load(ordering: .acquiring))

        let part2: ManagedAtomic<Int> = .init(0)
        DispatchQueue.concurrentPerform(iterations: batteryBanks.count) {
            part2.wrappingIncrement(by: batteryBanks[$0][...].battery(length: 12), ordering: .relaxed)
        }
        print("Part 2:", part2.load(ordering: .acquiring))

    }
}

extension ArraySlice<Int> {
    /// Returns the highest value battery of length in this array slice.
    func battery(length: Int) -> Int {
        guard length > 1 else { return self.max() ?? 0 }

        let power = Int(pow(10.0, Double(length - 1)))
        var value = 0
        for first in indices.dropLast(length - 1) {
            if self[first] * power > value {
                value = self[first] * power + self[(first+1)...].battery(length: length - 1)
            }
        }
        return value
    }
}