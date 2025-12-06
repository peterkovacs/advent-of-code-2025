import ArgumentParser
import Foundation 

struct Day6Part2: ParsableCommand {
    @Argument
    var input: String = #file

    func run() throws {
        let grid = try grid(file: input).mirrored

        var part2 = 0
        var values: [Int] = []
        var `operator`: (Int, Int) -> Int = (+)

        func sum() {
            guard !values.isEmpty else { return }
            part2 += values.dropFirst().reduce(values[0], `operator`)
            values = []
        }

        for col in 0..<grid.size.x {
            let value = grid.column(col).reduce(into: 0) {
                switch $1 {
                case "0"..."9": $0 = $0 * 10 + (Int(String($1)) ?? 0)
                case "*": `operator` = (*)
                case "+": `operator` = (+)
                case " ": break
                default: fatalError()
                }                
            }

            if value > 0 {
                values.append(value)
            } else {
                sum()
            }
        }

        sum()

        print("Part 2:", part2)
    }
}