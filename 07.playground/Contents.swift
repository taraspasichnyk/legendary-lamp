import UIKit

let testInput = """
"""

let taskInput = """
"""

func quantumTachyonManifold(inputString: String) -> (beamSplits: Int, paths: Int) {
    let rows = inputString.split(separator: "\n").map { String($0) }

    guard let startRow = rows.firstIndex(where: { $0.contains("S") }),
          let startCol = rows[startRow].firstIndex(of: "S")?.utf16Offset(in: rows[startRow]) else {
        return (0, 0)
    }

    // Track number of beams at each position
    var beamCounts: [Int: Int] = [startCol: 1]
    var totalActivatedSplits = Set<String>()

    for rowIndex in (startRow + 1)..<rows.count where rows[rowIndex].contains("^") {
        let row = rows[rowIndex]
        var nextBeamCounts: [Int: Int] = [:]

        for (col, count) in beamCounts {
            guard col >= 0 && col < row.count else { continue }
            let char = row[row.index(row.startIndex, offsetBy: col)]

            if char == "^" {
                totalActivatedSplits.insert("\(rowIndex)_\(col)")
                // Each beam splits into 2
                nextBeamCounts[col - 1, default: 0] += count
                nextBeamCounts[col + 1, default: 0] += count
            } else {
                // Beam continues straight
                nextBeamCounts[col, default: 0] += count
            }
        }

        beamCounts = nextBeamCounts
    }

    let totalPaths = beamCounts.values.reduce(0, +)
    return (totalActivatedSplits.count, totalPaths)
}

print(quantumTachyonManifold(inputString: taskInput))
