struct PasswordCracker {
    enum Rotation {
        case left(Int)
        case right(Int)

        var description: String {
            switch self {
            case .left(let change): "L\(change)"
            case .right(let change): "R\(change)"
            }
        }
    }

    private let rotationsRange = [0...99]
    private let startPosition: Int
    private let rotations: [Rotation]
    private let verbose: Bool

    init(
        startPosition: Int,
        rotations: [Rotation],
        verbose: Bool = false
    ) {
        self.startPosition = startPosition
        self.rotations = rotations
        self.verbose = verbose
    }

    func crackPassword() -> Int {
        var numberOfNils = 0
        var currentPosition = self.startPosition

        self.consolePrint("The dial starts by pointing at \(currentPosition).")

        for rotation in self.rotations {
            let change = {
                switch rotation {
                case .left(let change): -change
                case .right(let change): change
                }
            }()

            let numberOfNilsPassedOnRotation = {
                let numberOfFullCircles = abs(change) / 100
                let leftover = abs(change) - numberOfFullCircles * 100

                if currentPosition == 0 {
                    return numberOfFullCircles
                }

                let additionalNil = switch rotation {
                case .left: currentPosition - leftover < 0 ? 1 : 0
                case .right: currentPosition + leftover > 100 ? 1 : 0
                }
                return numberOfFullCircles + additionalNil
            }()

            currentPosition = (currentPosition + change % 100 + 100) % 100

            self.consolePrint("The dial is rotated \(rotation.description) to point at \(currentPosition).")
            if numberOfNilsPassedOnRotation > 0 {
                self.consolePrint("Nils on rotation: \(numberOfNilsPassedOnRotation)")
            }

            if currentPosition == 0 {
                numberOfNils += 1
            }

            numberOfNils += numberOfNilsPassedOnRotation
        }


        return numberOfNils
    }

    private func consolePrint(_ message: String) {
        if self.verbose {
            print(message)
        }
    }
}

let password = PasswordCracker(
    startPosition: 0,
    rotations: [
    ],
    verbose: true
).crackPassword()
