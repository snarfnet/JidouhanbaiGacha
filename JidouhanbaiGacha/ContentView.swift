import SwiftUI

struct ContentView: View {
    @State private var collection = Collection()
    @State private var currentDrink: Drink?
    @State private var showResult = false
    @State private var isDispensing = false
    @State private var showCollection = false
    @State private var shakeDetected = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header stats
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("自販機ガチャ")
                                .font(.title2).bold()
                                .foregroundStyle(.white)
                            Text("\(collection.count) / \(collection.total) 種類")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        Spacer()
                        Button {
                            showCollection = true
                        } label: {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.title2)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Progress bar
                    ProgressView(value: collection.progress)
                        .tint(.orange)
                        .padding(.horizontal)
                        .padding(.top, 4)

                    Spacer()

                    // Vending machine
                    if showResult, let drink = currentDrink {
                        DrinkCardView(drink: drink, isNew: !collection.has(drink.id))
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                            .onAppear {
                                collection.add(drink)
                            }
                    } else {
                        VendingMachineView(isDispensing: isDispensing)
                            .transition(.opacity)
                    }

                    Spacer()

                    // Dispense button
                    Button {
                        dispense()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: showResult ? "arrow.counterclockwise" : "hand.tap.fill")
                            Text(showResult ? "もう一回" : "ボタンを押す")
                                .bold()
                        }
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, Color(red: 0.9, green: 0.4, blue: 0.1)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .disabled(isDispensing)
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                    if !showResult {
                        Text("シェイクでもOK!")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.bottom, 8)
                    }
                }
            }
            .sheet(isPresented: $showCollection) {
                CollectionView(collection: collection)
            }
            .onShake {
                if !isDispensing {
                    dispense()
                }
            }
        }
    }

    private func dispense() {
        if showResult {
            withAnimation(.easeInOut(duration: 0.3)) {
                showResult = false
                currentDrink = nil
            }
            return
        }

        isDispensing = true
        withAnimation(.easeInOut(duration: 0.3)) {}

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let drink = DrinkGenerator.randomDrink()
            currentDrink = drink
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showResult = true
            }
            isDispensing = false
        }
    }
}

// MARK: - Vending Machine View

struct VendingMachineView: View {
    let isDispensing: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Machine body
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.3, green: 0.3, blue: 0.35), Color(red: 0.2, green: 0.2, blue: 0.25)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 260, height: 340)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                VStack(spacing: 12) {
                    // Display window
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.15, green: 0.2, blue: 0.3).opacity(0.8))
                        .frame(width: 220, height: 180)
                        .overlay {
                            // Drink rows
                            VStack(spacing: 8) {
                                ForEach(0..<3, id: \.self) { row in
                                    HStack(spacing: 12) {
                                        ForEach(0..<5, id: \.self) { col in
                                            let idx = row * 5 + col
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(sampleColor(for: idx))
                                                .frame(width: 28, height: 44)
                                        }
                                    }
                                }
                            }
                        }

                    // Dispense slot
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 180, height: 60)

                        if isDispensing {
                            Text("ガコン...")
                                .font(.headline)
                                .foregroundStyle(.orange)
                                .transition(.opacity)
                        } else {
                            Text("取り出し口")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                }
            }
        }
    }

    private func sampleColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink, .mint, .cyan, .indigo,
                                .red.opacity(0.7), .blue.opacity(0.7), .green.opacity(0.7), .orange.opacity(0.7), .purple.opacity(0.7)]
        return colors[index % colors.count]
    }
}

// MARK: - Drink Card View

struct DrinkCardView: View {
    let drink: Drink
    let isNew: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Rarity badge
            HStack {
                if isNew {
                    Text("NEW!")
                        .font(.caption).bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(.red))
                }
                Spacer()
                Text(drink.rarity.rawValue)
                    .font(.headline).bold()
                    .foregroundStyle(drink.rarity.color)
                HStack(spacing: 2) {
                    ForEach(0..<drink.rarity.stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
            }

            // Can illustration
            CanView(drink: drink)
                .frame(height: 160)

            // Name
            Text(drink.name)
                .font(.title3).bold()
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Info
            VStack(spacing: 4) {
                Label(drink.canShape.rawValue, systemImage: "cube")
                Label(drink.effect, systemImage: "sparkles")
                Text(drink.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [drink.color1.opacity(0.3), drink.color2.opacity(0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(drink.rarity.color.opacity(0.5), lineWidth: 2)
                )
        )
        .padding(.horizontal, 32)
    }
}

// MARK: - Can View

struct CanView: View {
    let drink: Drink

    var body: some View {
        ZStack {
            // Can shape
            switch drink.canShape {
            case .tall:
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [drink.color1, drink.color2], startPoint: .top, endPoint: .bottom))
                    .frame(width: 50, height: 130)
            case .short:
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [drink.color1, drink.color2], startPoint: .top, endPoint: .bottom))
                    .frame(width: 55, height: 90)
            case .bottle:
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(drink.color1)
                        .frame(width: 20, height: 30)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [drink.color1, drink.color2], startPoint: .top, endPoint: .bottom))
                        .frame(width: 50, height: 100)
                }
            case .pet:
                VStack(spacing: 0) {
                    Capsule()
                        .fill(drink.color1.opacity(0.5))
                        .frame(width: 16, height: 20)
                    Capsule()
                        .fill(LinearGradient(colors: [drink.color1, drink.color2], startPoint: .top, endPoint: .bottom))
                        .frame(width: 46, height: 110)
                }
            case .pack:
                Rectangle()
                    .fill(LinearGradient(colors: [drink.color1, drink.color2], startPoint: .top, endPoint: .bottom))
                    .frame(width: 55, height: 80)
                    .overlay(
                        Triangle()
                            .fill(drink.color1.opacity(0.5))
                            .frame(width: 55, height: 20)
                            .offset(y: -30)
                    )
            case .pouch:
                Capsule()
                    .fill(LinearGradient(colors: [drink.color1, drink.color2], startPoint: .top, endPoint: .bottom))
                    .frame(width: 60, height: 100)
            }

            // Label
            Text(String(drink.flavor.prefix(2)))
                .font(.title2).bold()
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 2)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Collection View

struct CollectionView: View {
    let collection: Collection
    @Environment(\.dismiss) private var dismiss
    @State private var filterRarity: Rarity?

    var filteredDrinks: [Drink] {
        let drinks = collection.collectedDrinks
        if let r = filterRarity {
            return drinks.filter { $0.rarity == r }
        }
        return drinks
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.08, green: 0.08, blue: 0.14)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Rarity breakdown
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "全て", count: collection.count, isSelected: filterRarity == nil) {
                                filterRarity = nil
                            }
                            ForEach(collection.rarityBreakdown, id: \.0) { rarity, count in
                                FilterChip(label: rarity.rawValue, count: count, color: rarity.color, isSelected: filterRarity == rarity) {
                                    filterRarity = filterRarity == rarity ? nil : rarity
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)

                    if filteredDrinks.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "cup.and.saucer")
                                .font(.system(size: 48))
                                .foregroundStyle(.white.opacity(0.3))
                            Text("まだ何もない...")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                                ForEach(filteredDrinks) { drink in
                                    CollectionItemView(drink: drink)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("コレクション")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let count: Int
    var color: Color = .orange
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.caption).bold()
                Text("\(count)")
                    .font(.caption2)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(isSelected ? color.opacity(0.6) : Color.white.opacity(0.1))
            )
        }
    }
}

struct CollectionItemView: View {
    let drink: Drink

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: [drink.color1.opacity(0.4), drink.color2.opacity(0.4)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: 80)

                Text(String(drink.flavor.prefix(2)))
                    .font(.title3).bold()
                    .foregroundStyle(.white)
            }

            Text(drink.rarity.rawValue)
                .font(.caption2).bold()
                .foregroundStyle(drink.rarity.color)

            Text(drink.name)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Shake Detection

struct ShakeDetector: UIViewControllerRepresentable {
    let onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let vc = ShakeViewController()
        vc.onShake = onShake
        return vc
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {
        uiViewController.onShake = onShake
    }

    class ShakeViewController: UIViewController {
        var onShake: (() -> Void)?

        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                onShake?()
            }
        }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.overlay(
            ShakeDetector(onShake: action)
                .allowsHitTesting(false)
        )
    }
}

#Preview {
    ContentView()
}
