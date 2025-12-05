import UIKit

let testInput = ""
let taskInput = ""
let splitInput = taskInput.components(separatedBy: "\n\n")

let ranges = splitInput[0].components(separatedBy: "\n").map({
    let bounds = $0.split(separator: "-").compactMap({ Int($0) })
    return bounds[0]...bounds[1]
})

let ids = splitInput[1].components(separatedBy: "\n").compactMap({ Int($0) })

func countFresh(ranges: [ClosedRange<Int>], ids: [Int]) -> Int {
    let a = ids.reduce(0) { count, id in
        for range in ranges {
            if range.contains(id) {
                return count + 1
            }
        }
        return count
    }
    return a
}

func countFreshIds(ranges: [ClosedRange<Int>]) -> Int {
    var aRanges = ranges

    while aRanges.contains(where: { range1 in
        aRanges.filter({ range2 in
            range2.overlaps(range1) && range1 != range2
        }).count > 0
    }) {
        var nonIntersectingRanges: [ClosedRange<Int>] = []

        for range in aRanges {
            print(nonIntersectingRanges)
            //        print(range)
            let containingRanges = aRanges.filter({ $0.overlaps(range) })

            print(containingRanges.count)
            if
                let lowestLowerBound = containingRanges.sorted(by: {
                    $0.lowerBound < $1.lowerBound
                }).first?.lowerBound,
                let highestUpperBound = containingRanges.sorted(by: {
                    $0.upperBound > $1.upperBound
                }).first?.upperBound {
                let resultingRange = lowestLowerBound...highestUpperBound
                //            print("Resulting range: \(resultingRange)")
                nonIntersectingRanges.append(resultingRange)

                for range in containingRanges {
                    if let index = aRanges.firstIndex(of: range) {
                        aRanges.remove(at: index)
                    }
                }
            }
        }

        aRanges = nonIntersectingRanges
        nonIntersectingRanges = []
    }

    return aRanges.reduce(0) {
        $0 + ($1.upperBound - $1.lowerBound) + 1
    }
}

//print(countFresh(ranges: ranges, ids: ids))

let start = Date()

print(countFreshIds(ranges: ranges))

print(Date().timeIntervalSince(start))
