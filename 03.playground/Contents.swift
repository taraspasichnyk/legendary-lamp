import Foundation

let testBatteries: [String] = []

let batteries: [String] = []

func getJoltage1(_ batteries: [String]) -> Int {
    let start = Date()

    var sum = 0

    for battery in batteries {
        var value = battery
        var firstBattery = 0
        var secondBattery = 0

        while value.count > 0 {
            if let joltage = Int(String(value.removeLast())) {
                if firstBattery == 0 {
                    firstBattery = joltage
                } else if joltage > firstBattery {
                    if secondBattery < firstBattery {
                        secondBattery = firstBattery
                    }
                    firstBattery = joltage
                } else if joltage < firstBattery {
                    if secondBattery == 0 {
                        secondBattery = firstBattery
                        firstBattery = joltage
                    }
                } else if joltage == firstBattery {
                    if secondBattery < joltage {
                        secondBattery = joltage
                    }
                }
            }
        }

        sum += firstBattery * 10 + secondBattery
    }

    print(Date.now.timeIntervalSince(start))
    return sum
}

func getJoltage2(_ batteries: [String]) -> Int {
    let start = Date()

    var sum = 0

    for battery in batteries {
        let chars = Array(battery)
        var result: [Character] = []

        var startIndex = 0
        var remaining = 12

        while remaining > 0 {
            let endIndex = chars.count - remaining

            var bestChar: Character = "0"
            var bestIndex: Int = startIndex

            for i in startIndex...endIndex {
                let char = chars[i]
                if char > bestChar {
                    bestChar = char
                    bestIndex = i
                    if bestChar == "9" {
                        break
                    }
                }
            }

            result.append(bestChar)
            startIndex = bestIndex + 1
            remaining -= 1
        }

        sum += Int(String(result)) ?? 0
    }

    print(Date.now.timeIntervalSince(start))
    return sum
}

print("Sum: \(getJoltage2(batteries))")
