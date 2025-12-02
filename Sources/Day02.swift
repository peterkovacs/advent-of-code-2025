import ArgumentParser
import Atomics
import Foundation
import Parsing

struct Day2: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [ClosedRange<Int>]> {
        Many {
            Parse { 
                $0...$1
            } with: {
                Int.parser()
                "-".utf8
                Int.parser()
            }
        } separator: {
            ",".utf8
        } terminator: {
            Whitespace(.vertical)
            End()
        }
    }
    

    func run() throws {
        let ranges = try parsed()

        let part1 = ManagedAtomic<Int>(0)
        DispatchQueue.concurrentPerform(iterations: ranges.count) {
            for i in ranges[$0] {
                if i.hasRepeatingDigits(length: Int((Double(i.digits()) / 2.0) + 0.5)) {
                    part1.wrappingIncrement(by: i, ordering: .relaxed)
                }
            }
        }

        print("Part 1:", part1.load(ordering: .acquiring))

        let part2 = ManagedAtomic<Int>(0)
        DispatchQueue.concurrentPerform(iterations: ranges.count) {
            for i in ranges[$0] {
            nextValue:
                for n in 0...(Int((Double(i.digits()) / 2.0) + 0.5)) {
                    if i.hasRepeatingDigits(length: n) {
                        part2.wrappingIncrement(by: i, ordering: .relaxed)
                        break nextValue
                    }
                }
            }
        }

        print("Part 2:", part2.load(ordering: .acquiring))
    }
}

fileprivate extension Int {
    func digits() -> Int {
        Int(log10(Double(self.magnitude))) + 1
    }

    func hasRepeatingDigits(length: Int) -> Bool {
        guard digits().isMultiple(of: length) else { return false }
        let modulo = Int(pow(10.0, Double(length)))

        let remainder = self % modulo

        guard remainder > 0 else { return false }

        let dividend = self / modulo

        if (dividend % modulo) != remainder {
            return false
        } else if dividend > modulo  {
            return dividend.hasRepeatingDigits(length: length)
        } else {
            return true
        }
    }
}