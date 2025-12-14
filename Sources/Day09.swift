import ArgumentParser
import Collections
import Foundation
import Parsing

struct Day9: ParsingCommand {
    @Argument var input: String = #file
    static var parser: some Parser<Substring.UTF8View, [Coord]> {
        Many {
            Parse(Coord.init) {
                Int.parser()
                ",".utf8
                Int.parser()
            }
        } separator: {
            Whitespace(.vertical)
        } terminator: {
            Whitespace(0...1, .vertical)
            End()
        }
    }

    func run() throws {
        let points = try parsed(file: input)

        guard
            let part1 = points
                .combinations(ofCount: 2)
                .map({ abs($0[0].x - $0[1].x + 1) * abs($0[0].y - $0[1].y + 1) })
                .max()
        else { return }

        print("Part 1:", part1)

        // Instead of solving this generally, we're going to solve our specific input. :(
        // There is a concavity at:
        //   1560,50063
        //   94601,50063
        //   94601,48706
        //   1675,48706
        // Going to assume that we can split our inputs into two parts, those above 50063, and those below 48706
        // Not only that, but one of the points must be 94601,50063 or 94601,48706 given the shape of the input.

        let (bottomHalf, topHalf) = points.filter { $0.y <= 48706 || $0.y >= 50063 }.partitioned { $0.y <= 48706 }

        let part2Top = topHalf
            .map { ($0, Rect(p1: .init(x: 94601, y: 48706), p2: $0)) }
            .filter { p, rect in
                return !topHalf.contains {
                    $0 != p &&
                    $0.x != rect.minX && $0.x != rect.maxX &&
                    $0.y != rect.maxY && $0.y != rect.minY &&
                    rect.contains($0)
                }
            }
            .max { $0.1.area < $1.1.area }

        let part2Bottom = bottomHalf
            .map { ($0, Rect(p1: .init(x: 94601, y: 50063), p2: $0)) }
            .filter { p, rect in
                return !bottomHalf.contains {
                    $0 != p &&
                    $0.x != rect.minX && $0.x != rect.maxX &&
                    $0.y != rect.maxY && $0.y != rect.minY &&
                    rect.contains($0)
                }
            }
            .max { $0.1.area < $1.1.area }

        if let part2Top {
            print("<polygon points=\"\(part2Top.1.corners.map { "\($0.x),\($0.y)" }.joined(separator: " "))\" fill=\"blue\" />")
        }
        if let part2Bottom {
            print("<polygon points=\"\(part2Bottom.1.corners.map { "\($0.x),\($0.y)" }.joined(separator: " "))\" fill=\"blue\" />")
        }

        print("Part 2:", max(part2Top?.1.area ?? 0, part2Bottom?.1.area ?? 0))

////        print(points)
//        let (_, _, horizontal, vertical) = points
//            .cycled()
//            .adjacentPairs()
//            .prefix(points.count)
//            .reduce(
//                into: (
//                    previous: points[points.count - 1].direction(to: points[0])!,
//                    inside: points[0].direction(to: points[1])!.right.right, // TODO: ???
//                    horizontal: [(inside: Coord.Direction, p1: Coord, p2: Coord)](),
//                    vertical: [(inside: Coord.Direction, p1: Coord, p2: Coord)]()
//                )
//            ) {
//                let direction = $1.0.direction(to: $1.1)!
//                let (p1, p2) = ($1.0.x == $1.1.x) ? ($1.0.y < $1.1.y ? ($1.0, $1.1) : ($1.1, $1.0)) : ($1.0.x < $1.1.x ? ($1.0, $1.1) : ($1.1, $1.0))
////                print("previous: \($0.previous) direction: \(direction) inside: \($0.inside) p0: \(p1) p1: \(p2)")
//
//                switch ($0.previous, direction) {
//                case (\.right, \.right), (\.left, \.left):
//                    $0.horizontal.append((inside: $0.inside, p1: p1, p2: p2))
//                case (\.up, \.up), (\.down, \.down):
//                    $0.vertical.append((inside: $0.inside, p1: p1, p2: p2))
//
//                case (\.right, \.down), (\.left, \.up):
//                    $0.inside = $0.inside.right
//                    print("--> inside:\($0.inside)")
//                    $0.vertical.append((inside: $0.inside, p1: p1, p2: p2))
//                case (\.right, \.up), (\.left, \.down):
//                    $0.inside = $0.inside.left
//                    print("--> inside:\($0.inside)")
//                    $0.vertical.append((inside: $0.inside, p1: p1, p2: p2))
//
//                case (\.up, \.right), (\.down, \.left):
//                    $0.inside = $0.inside.right
//                    print("--> inside:\($0.inside)")
//                    $0.horizontal.append((inside: $0.inside, p1: p1, p2: p2))
//                case (\.up, \.left), (\.down, \.right):
//                    $0.inside = $0.inside.left
//                    print("--> inside:\($0.inside)")
//                    $0.horizontal.append((inside: $0.inside, p1: p1, p2: p2))
//                default: fatalError("\($0.previous), \(direction)")
//                }
//
//                $0.previous = direction
//            }
//
//        func intersects(corners: [Coord]) -> Bool {
//            let (a, b) = (corners[0], corners[1])
//            let minX = min(a.x, b.x)
//            let maxX = max(a.x, b.x)
//            let minY = min(a.y, b.y)
//            let maxY = max(a.y, b.y)
//
//            // reject any rectangle with 0 area.
//            guard minX < maxX, minY < maxY else { return true }
//
//            return horizontal.contains { (inside, p1, p2) in
//                switch inside {
//                case \.up:
//                    (minY <= p1.y && p1.y < maxY) &&
//                    ( (p1.x <= minX && minX < p2.x) ||
//                      (p1.x < maxX && maxX <= p2.x) )
//                case \.down:
//                    (minY < p1.y && p1.y <= maxY) &&
//                    ( (p1.x <= minX && minX < p2.x) ||
//                      (p1.x < maxX && maxX <= p2.x) )
//                default: fatalError()
//                }
//            } || vertical.contains { (inside, p1, p2) in
//                switch inside {
//                case \.left:
//                    (minX <= p1.x && p1.x < maxX) &&
//                    ( (p1.y <= minY && minY < p2.y) ||
//                      (p1.y < maxY && maxY <= p2.y) )
//                case \.right:
//                    (minX < p1.x && p1.x <= maxX) &&
//                    ( (p1.y <= minY && minY < p2.y) ||
//                      (p1.y < maxY && maxY <= p2.y) )
//                default: fatalError()
//                }
//            }
//        }
//
//        let valid = points
//            .combinations(ofCount: 2)
//            .filter { !intersects(corners: $0) }
//
//        guard
//            let part2 = valid
//                .map({ abs($0[0].x - $0[1].x + 1) * abs($0[0].y - $0[1].y + 1) })
//                .max()
//        else { return }
//
//        print("Part 2:", part2)
    }
}
