import Foundation

enum InputParser {
    static func parse(string: String) -> [ClosedRange<Int>] {
        let rangeStrings = string.split(separator: ",")

        let ranges: [ClosedRange<Int>] = rangeStrings.compactMap { rangeString in
            let bounds = rangeString.split(separator: "-").compactMap { Int($0) }
            guard bounds.count == 2 else { return nil }
            return bounds[0]...bounds[1]
        }

        return ranges
    }
}

struct Asd {
    let ranges: [ClosedRange<Int>]

    func compute1() -> Int {
        var sum = 0

        for range in ranges {
            for value in range {
                let string = String(value)
                if string.count.isMultiple(of: 2) {
                    let partSize = string.count / 2

                    let stringArray = string.compactMap(\.wholeNumberValue)

                    if stringArray[0..<partSize] == stringArray[partSize..<string.count] {
                        sum += value
                    }
                }
            }
        }

        return sum
    }

    let regex = try! Regex("^(.+)\\1+$")

    func compute2() -> Int {
        var sum = 0

        for range in ranges {
            for value in range {
                let string = String(value)
                if !string.ranges(of: self.regex).isEmpty {
                    sum += value
                }
            }
        }

        return sum
    }
}

let testInput = ""

let myInput = ""

let ranges = InputParser.parse(string: myInput)

//print(ranges)

let sum = Asd(ranges: ranges).compute2()

print("Result: \(sum)")
