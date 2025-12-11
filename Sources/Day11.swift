import ArgumentParser
import Foundation
import Parsing

struct Day11: ParsingCommand {
    static var parser: some Parser<Substring.UTF8View, [(String, [String])]> {
        Many {
            PrefixUpTo(":".utf8).map(.string)
            ": ".utf8
            Many {
                From(.substring) {
                    Prefix(while: \.isLetter)
                }.map(.string)
            } separator: {
                Whitespace(1, .horizontal)
            } terminator: {
                Whitespace(.vertical)
            }
        } separator: {
            Whitespace(.vertical)
        }
    }

    func dfs(node: String, paths: [String:[String]]) -> Int {
        if node == "out" { return 1 }
        guard let pathsFromNode = paths[node] else { return 0 }

        return pathsFromNode.reduce(0) { total, path in
            total + dfs(node: path, paths: paths)
        }
    }

    struct Key: Hashable {
        let node: String
        let dac, fft: Bool
    }
    func dfs(node: String, paths: [String:[String]], visited: inout [Key:Int], dac: Bool, fft: Bool) -> Int {
        let key = Key(node: node, dac: dac, fft: fft)
        if node == "out" {
            visited[key] = dac && fft ? 1 : 0
            return dac && fft ? 1 : 0
        }

        if let visitedCount = visited[key] { return visitedCount }
        guard let pathsFromNode = paths[node] else { return 0 }

        var total = 0
        for node in pathsFromNode {
            total += dfs(node: node, paths: paths, visited: &visited, dac: dac || node == "dac", fft: fft || node == "fft")
        }

        visited[key] = total
        return total
    }

    func run() throws {
        let input = Dictionary(try parsed()) {
            var a = $0
            a.append(contentsOf: $1)
            return a
        }

        let part1 = dfs(node: "you", paths: input)
        print("Part 1:", part1)

        var visited: [Key:Int] = .init()
        let part2 = dfs(node: "svr", paths: input, visited: &visited, dac: false, fft: false)
        print("Part 2:", part2)

    }
}
