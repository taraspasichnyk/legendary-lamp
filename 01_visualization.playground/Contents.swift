import SwiftUI
import PlaygroundSupport
import Foundation

struct Lockpick: View {
    @State private var isOn: Bool = false
    @State private var isLocked: Bool = true
    @State var shake = false
    @State var switchOffset: CGFloat = -56
    @ObservedObject var passwordCracker = PasswordCracker(
        startPosition: 50,
        rotations: [
            .left(68),
            .left(30),
            .right(48),
            .left(5),
            .right(60),
            .left(55),
            .left(1),
            .left(99),
            .right(14),
            .left(82)
        ]
    )

    var body: some View {
        VStack(spacing: 16) {
            Text("the North Pole background (trust)")
                .foregroundStyle(.black)
                .onSelect {
                    self.switchOffset = self.switchOffset == 0 ? -64 : 0
                }

            Toggle(isOn: self.$isOn) {
                Text("password method 0x434C49434B")
                    .font(.footnote)
            }

            ZStack(alignment: .center) {
                Rectangle()
                    .frame(width: 280, height: 420)
                    .padding(12)
                    .background(.green)

                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48)
                            .foregroundStyle(self.isLocked ? .red : .green)
                            .onTapGesture {
                                if let password = self.passwordCracker.password {
                                    self.openDoors(password: password)
                                } else {
                                    self.shake = true
                                }
                            }
                            .shake(self.$shake) {
                            }

                    if self.isLocked {
                        VStack(spacing: 8) {
                            ZStack(alignment: .center) {
                                SafeKnobView(value: self.$passwordCracker.currentPosition)

                                Text(String(self.passwordCracker.currentPosition))
                                    .font(.system(size: 18, weight: .regular, design: .monospaced))
                                    .animation(.default, value: self.passwordCracker.currentRotation?.description)
                                    .contentTransition(.numericText())

                                if let rotation = self.passwordCracker.currentRotation, self.passwordCracker.password == nil {
                                    Text(rotation.description)
                                        .offset(y: 60)
                                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.blue)
                                        .opacity(self.passwordCracker.currentRotation != nil ? 1 : 0)
                                        .animation(.default, value: self.passwordCracker.currentRotation?.description)
                                        .contentTransition(.numericText())
                                }
                            }
                            .foregroundStyle(self.passwordCracker.password == nil ? .red : .green)
                            .onSelect {
                                self.passwordCracker.crackPassword(usesNewProtocol: self.isOn)
                            }
                        }
                    }
                }
            }
            .offset(y: self.switchOffset)
            .frame(height: 420)
            .padding(16)
            .animation(.default, value: self.isLocked)
            .animation(.default, value: self.switchOffset)
        }
        .padding(16)
    }

    private func openDoors(password: Int) {
        guard password == 6 else {
            self.doorOpeningFailure()

            return
        }

        self.doorOpeningSuccess()
    }

    private func doorOpeningSuccess() {
        self.isLocked = false
    }

    private func doorOpeningFailure() {
        self.passwordCracker.reset()

        self.shake = true
    }
}

let view = Lockpick()
let hostingVC = UIHostingController(rootView: view)
PlaygroundPage.current.liveView = hostingVC

@MainActor
class PasswordCracker: ObservableObject {
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

    @Published var password: Int?
    @Published var currentPosition: Int
    @Published var currentRotation: Rotation?

    private var crackingTask: Task<Void, Never>?

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
        self.currentPosition = startPosition
        self.rotations = rotations
        self.verbose = verbose
    }

    func crackPassword(usesNewProtocol: Bool) {
        self.crackingTask?.cancel()
        self.crackingTask = Task {
            self.reset()

            var numberOfNils = 0
            self.currentPosition = self.startPosition

            for rotation in self.rotations {
                let change = {
                    switch rotation {
                    case .left(let change): -change
                    case .right(let change): change
                    }
                }()

                let numberOfNilsPassedOnRotation = {
                    guard usesNewProtocol else {
                        return 0
                    }

                    let numberOfFullCircles = abs(change) / 100
                    let leftover = abs(change) - numberOfFullCircles * 100

                    if self.currentPosition == 0 {
                        return numberOfFullCircles
                    }

                    let additionalNil = switch rotation {
                    case .left: self.currentPosition - leftover < 0 ? 1 : 0
                    case .right: self.currentPosition + leftover > 100 ? 1 : 0
                    }
                    return numberOfFullCircles + additionalNil
                }()

                try! await Task.sleep(for: .seconds(0.8))

                self.currentRotation = rotation
                self.currentPosition = (self.currentPosition + change % 100 + 100) % 100

                if self.currentPosition == 0 {
                    numberOfNils += 1
                }

                numberOfNils += numberOfNilsPassedOnRotation
            }


            self.password = numberOfNils
        }
    }

    func reset() {
        self.password = nil
        self.currentRotation = nil
        self.currentPosition = self.startPosition
    }
}

struct SafeKnobView: View {
    @Binding var value: Int
    var lineCount: Int = 100
    var size: CGFloat = 86

    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<self.lineCount, id: \.self) { i in
                Rectangle()
                    .fill(.red)
                    .frame(width: 1, height: i % 5 == 0 ? 14 : 7)
                    .offset(y: -self.size/2 + 5)
                    .rotationEffect(.degrees(Double(i) / Double(self.lineCount) * 360))
            }

            Circle()
                .stroke(lineWidth: 4)
                .frame(width: size, height: size)
        }
        .frame(width: self.size, height: self.size)
        .rotationEffect(.degrees(self.rotationAngle))
        .onChange(of: self.value) { newValue in
            self.animateToValue(newValue)
        }
        .onAppear {
            self.rotationAngle = self.angle(for: self.value)
        }
    }

    private func angle(for value: Int) -> Double {
        Double(value) / 100.0 * 360.0
    }

    private func animateToValue(_ newValue: Int) {
        let newAngle = self.angle(for: newValue)
        let delta = (newAngle - self.rotationAngle).truncatingRemainder(dividingBy: 360)

        let shortestDelta: Double
        if delta > 180 {
            shortestDelta = delta - 360
        } else if delta < -180 {
            shortestDelta = delta + 360
        } else {
            shortestDelta = delta
        }

        withAnimation(.easeInOut(duration: 0.5)) {
            self.rotationAngle += shortestDelta
        }
    }
}

public extension View {
    func onSelect(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .simultaneousGesture(TapGesture())
    }
}

// Source - https://stackoverflow.com/a
// Posted by Edudjr, modified by community. See post 'Timeline' for change history
// Retrieved 2025-12-01, License - CC BY-SA 4.0

struct Shake<Content: View>: View {
    /// Set to true in order to animate
    @Binding var shake: Bool
    /// How many times the content will animate back and forth
    var repeatCount = 3
    /// Duration in seconds
    var duration = 0.8
    /// Range in pixels to go back and forth
    var offsetRange = 10.0

    @ViewBuilder let content: Content
    var onCompletion: (() -> Void)?

    @State private var xOffset = 0.0

    var body: some View {
        content
            .offset(x: xOffset)
            .onChange(of: shake) { shouldShake in
                guard shouldShake else { return }
                Task {
                    let start = Date()
                    await animate()
                    let end = Date()
                    print(end.timeIntervalSince1970 - start.timeIntervalSince1970)
                    shake = false
                    onCompletion?()
                }
            }
    }

    // Obs: sum of factors must be 1.0.
    private func animate() async {
        let factor1 = 0.9
        let eachDuration = duration * factor1 / CGFloat(repeatCount)
        for _ in 0..<repeatCount {
            await backAndForthAnimation(duration: eachDuration, offset: offsetRange)
        }

        let factor2 = 0.1
        await animate(duration: duration * factor2) {
            xOffset = 0.0
        }
    }

    private func backAndForthAnimation(duration: CGFloat, offset: CGFloat) async {
        let halfDuration = duration / 2
        await animate(duration: halfDuration) {
            self.xOffset = offset
        }

        await animate(duration: halfDuration) {
            self.xOffset = -offset
        }
    }
}

extension View {
    func shake(_ shake: Binding<Bool>,
               repeatCount: Int = 3,
               duration: CGFloat = 0.8,
               offsetRange: CGFloat = 10,
               onCompletion: (() -> Void)? = nil) -> some View {
        Shake(shake: shake,
              repeatCount: repeatCount,
              duration: duration,
              offsetRange: offsetRange) {
            self
        } onCompletion: {
            onCompletion?()
        }
    }

    func animate(duration: CGFloat, _ execute: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            withAnimation(.linear(duration: duration)) {
                execute()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                continuation.resume()
            }
        }
    }
}
