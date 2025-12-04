import Foundation

let testShelves: [String] = []

let taskShelves: [String] = []

extension Array {
    var prettyPrinted: String {
        self.map { "\($0)" }.joined(separator: "\n")
    }
}

func countRolls(_ shelves: [[String]]) -> Int {
    let a = shelves.map({ $0.reduce("", { $0 + $1 }) })
    //    print(a.prettyPrinted)
    return countRolls(a)
}

func countRolls(_ shelves: [String]) -> Int {
    //    print(shelves.prettyPrinted)

    var convertedShelves = shelves.map({ $0.map { String($0) } })

    var rollCount = 0

    let currentShelves = convertedShelves

    for (i, shelf) in currentShelves.enumerated() {
        var adjacentRolls = 0

        for (j, char) in shelf.enumerated() {
            adjacentRolls = 0

            if char == "@" {
                let lowerIBound = max(0, i - 1)
                let upperIBound = min(currentShelves.count - 1, i + 1)

                let lowerJBound = max(0, j - 1)
                let upperJBound = min(shelf.count - 1, j + 1)

                for k in lowerIBound...upperIBound {
                    for l in lowerJBound...upperJBound {

                        if k == i && l == j {
                            continue
                        }

                        if currentShelves[k][l] == "@" {
                            adjacentRolls += 1
                        }
                    }
                }

                if adjacentRolls < 4 {
                    rollCount += 1
                    convertedShelves[i][j] = "."
                }
            }
        }
    }
    // first
    // return rollCount
    return rollCount + (convertedShelves.contains(where: { $0.contains("@") }) && rollCount > 0 ? countRolls(convertedShelves) : 0)
}

let start1 = Date()
print(countRolls(testShelves))
print("Execution time: \(Date().timeIntervalSince(start1))\n")

let start2 = Date()
print(countRolls(taskShelves))
print("Execution time: \(Date().timeIntervalSince(start2))\n")

