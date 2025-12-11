import ArgumentParser
import Collections
import Foundation
import Parsing
import SwiftZ3

struct Day10: ParsingCommand {
    @Argument var input = #file
    static var parser: some Parser<Substring.UTF8View, [([Bool], [[Int]], [Int])]> {
        Many {
            Parse {
                "[".utf8
                Many {
                    OneOf {
                        ".".utf8.map { false }
                        "#".utf8.map { true  }
                    }
                }
                "]".utf8
                Whitespace(.horizontal)

                Many {
                    "(".utf8
                    Many {
                        Int.parser()

                    } separator: {
                        ",".utf8
                    }
                    ")".utf8
                } separator: {
                    Whitespace(.horizontal)
                } terminator: {
                    Whitespace(.horizontal)
                }

                "{".utf8
                Many {
                    Int.parser()
                } separator: {
                    ",".utf8
                }
                "}".utf8
            }
        } separator: {
            Whitespace(.vertical)
        } terminator: {
            End()
        }
    }

    func run() throws {
        let input = try parsed(file: input)

        let part1 = input.reduce(into: 0) { $0 += configure(lights: $1.0, buttons: $1.1) }
        print("Part 1:", part1)

        let part2 = input.reduce(into: 0) { $0 += configure(joltage: $1.2, buttons: $1.1) }
        print("Part 2:", part2)

    }

    func configure(lights: [Bool], buttons: [[Int]]) -> Int {
        var seen: Set<[Bool]> = []
        var queue: Deque = .init(
            buttons.map {
                (
                    [Bool](repeating: false, count: lights.count),
                    0,
                    $0,
                )
            }
        )

        while let (l, count, b) = queue.popFirst() {
            let l = b.reduce(into: l) { $0[$1].toggle() }

            if l == lights { return count + 1 }

            guard seen.insert(l).inserted else {
                continue
            }

            queue.append(contentsOf: buttons.map {
                (
                    l,
                    count + 1,
                    $0,
                )
            })
        }

        fatalError()
    }

    func configure(joltage: [Int], buttons: [[Int]]) -> Int {
        let config: Z3Config = {
            let config = Z3Config()
            config.setParameter(name: "model", value: "true")
            return config
        }()

        let context: Z3Context = Z3Context(configuration: config)
        let solver = context.makeOptimize()

        let b = buttons.enumerated().map {
            let i = context.makeConstant(name: "b\($0.offset)", sort: IntSort.self)
            solver.assert(i >= 0)
            return i
        }

        for i in joltage.indices {
            let applicableButtons = buttons.indices.filter { buttons[$0].contains(i) }
            solver.assert(applicableButtons.dropFirst().reduce(b[applicableButtons[0]]) { $0 + b[$1] } == context.makeInteger64(Int64(joltage[i])))
        }

        _ = solver.minimize(b.indices.dropFirst().reduce(b[0]) { $0 + b[$1] })
        // print(solver.getAssertions().toString())
        // print(solver.getModel().toString())

        if solver.check() == .satisfiable {
            let model = solver.getModel()
            return Int(b.reduce(0) { $0 + model.int64($1) })
        } else {
            fatalError()
        }
    }
}
