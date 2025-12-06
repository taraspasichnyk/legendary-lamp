import UIKit

let testInput1 = """
"""

let testInput2 = """
"""

let taskInput = """
"""

func calculate1(rows: [[String]]) -> Int {
    var sum = 0
    
    var workRows = rows
    let operations = workRows.removeLast()

    for (i, operation) in operations.enumerated() {
        if operation == "+" {
            let value = workRows.map({ $0[i] }).compactMap({ Int($0) }).reduce(0, +)
            sum += value
        } else if operation == "*" {
            let value = workRows.map({ $0[i] }).compactMap({ Int($0) }).reduce(1, *)
            sum += value
        }
    }

    return sum
}

var input1 = testInput1

let rows1 = input1.split(separator: "\n").map({ $0.split(separator: " ").map({ String($0) }) })

print(calculate1(rows: rows1))
print("\n")

extension String {
    subscript(i: Int) -> Character {
        get {
            self[index(startIndex, offsetBy: i)]
        }
        set {
            var chars = Array(self)
            chars[i] = newValue
            self = String(chars)
        }
    }
}


func calculate2(input: String) -> Int {
    var sum = 0

    let rows = input.split(separator: "\n").map({ String($0) })
    var workRows = rows
    let operations = workRows.removeLast().split(separator: " ")

//    var outputRows = [[String]](repeating: operations.map({ _ in "" }), count: workRows.count)
//
//    print(outputRows)

    print(workRows)

    let maxCount = workRows.map(\.count).max()!

    for i in 0..<maxCount {
        if workRows.contains(where: { $0[i] != " " }) {
            for j in 0..<workRows.count {
                if workRows[j][i] == " " {
                    workRows[j][i] = "0"
                }
            }
        }
    }

    let convertedRows = workRows.map({ $0.split(separator: " ") })
    print(convertedRows)

    for (i, operation) in operations.enumerated() {
        let values = convertedRows.map({ $0[i] })
        print(values)
        var normalizedValues: [String] = values.map({ _ in "" })

        for (i, value) in values.enumerated() {
            var value = value

            while !value.isEmpty {
                for j in 0..<normalizedValues.count {
                    if let last = value.last {
                        if last == "0" {
                            value.removeLast()
                        } else {
                            normalizedValues[j] = "\(value.removeLast())\(normalizedValues[j])"
                        }
                    }
                }
            }
        }

        let value = normalizedValues.compactMap({ Int(String($0.reversed())) })

        if operation == "+" {
            let result = value.reduce(0, +)
            print(result)
            sum += result
        } else if operation == "*" {
            let result = value.reduce(1, *)
            print(result)
            sum += result
        }
    }

    return sum
}

var input2 = taskInput

let spaceRanges = input2.ranges(of: " ")

print(input2)
print("\n")

print(calculate2(input: input2))
