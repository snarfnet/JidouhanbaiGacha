import SwiftUI

struct ContentView: View {
    @State private var collection = Collection()
    @State private var currentDrink: Drink?
    @State private var showResult = false
    @State private var isDispensing = false
    @State private var showCollection = false

    var body: some View {
        NavigationStack {
            ZStack {
                GachaBackground()

                VStack(spacing: 0) {
                    header
                    ProgressView(value: collection.progress)
                        .tint(.orange)
                        .padding(.horizontal, 20)

                    Spacer()

                    if showResult, let currentDrink {
                        DrinkCardView(drink: currentDrink, isNew: !collection.has(currentDrink.id))
                            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                            .onAppear { collection.add(currentDrink) }
                    } else {
                        VendingMachineView(isDispensing: isDispensing)
                            .transition(.opacity)
                    }

                    Spacer()

                    Button(action: dispense) {
                        Label(showResult ? "もう一回まわす" : "ボタンを押す", systemImage: showResult ? "arrow.counterclockwise" : "hand.tap.fill")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 18))
                            .shadow(color: .orange.opacity(0.35), radius: 18, y: 8)
                    }
                    .disabled(isDispensing)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    if !showResult {
                        Text("シェイクでもOK")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(.bottom, 12)
                    }
                }
            }
            .sheet(isPresented: $showCollection) {
                CollectionView(collection: collection)
            }
            .onShake {
                if !isDispensing { dispense() }
            }
        }
        .safeAreaInset(edge: .bottom) {
            AdMobBannerView(adUnitID: AdMobConfig.bannerAdUnitID)
                .background(.black.opacity(0.76))
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("自販機ガチャ")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("\(collection.count) / \(collection.total) 種類")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.66))
            }
            Spacer()
            Button {
                showCollection = true
            } label: {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 46, height: 46)
                    .background(.white.opacity(0.10), in: Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private func dispense() {
        if showResult {
            withAnimation(.easeInOut(duration: 0.25)) {
                showResult = false
                currentDrink = nil
            }
            return
        }

        isDispensing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            currentDrink = DrinkGenerator.randomDrink()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                showResult = true
            }
            isDispensing = false
        }
    }
}

struct VendingMachineView: View {
    let isDispensing: Bool
    private var machineWidth: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 400 : 320
    }
    private var machineHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 450 : 360
    }

    var body: some View {
        ZStack {
            Image("HeroArtwork")
                .resizable()
                .scaledToFit()
                .frame(width: machineWidth, height: machineHeight)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.18)))
                .shadow(color: .black.opacity(0.45), radius: 24, y: 14)

            VStack {
                Spacer()
                Text(isDispensing ? "ガコン..." : "PUSH")
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundStyle(isDispensing ? .orange : .white.opacity(0.78))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.52), in: Capsule())
                    .padding(.bottom, 28)
            }
            .frame(width: machineWidth, height: machineHeight)
        }
        .contentShape(Rectangle())
    }
}

struct DrinkCardView: View {
    let drink: Drink
    let isNew: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                if isNew {
                    Text("NEW")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(.red, in: Capsule())
                }
                Spacer()
                Text(drink.rarity.rawValue)
                    .font(.headline.weight(.black))
                    .foregroundStyle(drink.rarity.color)
                HStack(spacing: 2) {
                    ForEach(0..<drink.rarity.stars, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
            }

            CanView(drink: drink)
                .frame(height: 160)

            Text(drink.name)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            VStack(spacing: 5) {
                Label(drink.canShape.rawValue, systemImage: "shippingbox")
                Label(drink.effect, systemImage: "sparkles")
                Text(drink.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.64))
                    .multilineTextAlignment(.center)
            }
            .font(.caption.bold())
            .foregroundStyle(.white.opacity(0.84))
        }
        .padding(20)
        .background(LinearGradient(colors: [drink.color1.opacity(0.35), drink.color2.opacity(0.32)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(drink.rarity.color.opacity(0.55), lineWidth: 2))
        .padding(.horizontal, 30)
    }
}

struct CanView: View {
    let drink: Drink

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(LinearGradient(colors: [drink.color1, drink.color2], startPoint: .top, endPoint: .bottom))
                .frame(width: width, height: height)
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.white.opacity(0.26))
                        .frame(width: width * 0.7, height: 8)
                        .padding(.top, 8)
                }
                .shadow(color: drink.color1.opacity(0.45), radius: 18, y: 8)

            Text(String(drink.flavor.prefix(2)))
                .font(.title2.weight(.black))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.7), radius: 3)
        }
    }

    private var width: CGFloat {
        switch drink.canShape {
        case .short, .pack: return 72
        case .pouch: return 78
        default: return 58
        }
    }

    private var height: CGFloat {
        switch drink.canShape {
        case .short, .pack: return 100
        case .tall, .pet, .bottle: return 142
        case .pouch: return 116
        }
    }
}

struct CollectionView: View {
    let collection: Collection
    @Environment(\.dismiss) private var dismiss
    @State private var filterRarity: Rarity?

    private var filteredDrinks: [Drink] {
        if let filterRarity {
            return collection.collectedDrinks.filter { $0.rarity == filterRarity }
        }
        return collection.collectedDrinks
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.06, blue: 0.12).ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "すべて", count: collection.count, isSelected: filterRarity == nil) {
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
                    .padding(.vertical, 10)

                    if filteredDrinks.isEmpty {
                        ContentUnavailableView("まだ何もありません", systemImage: "cup.and.saucer", description: Text("ガチャを回すとここに並びます。"))
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
            Text("\(label) \(count)")
                .font(.caption.bold())
                .foregroundStyle(isSelected ? .white : .white.opacity(0.62))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(isSelected ? color.opacity(0.65) : .white.opacity(0.10), in: Capsule())
        }
    }
}

struct CollectionItemView: View {
    let drink: Drink

    var body: some View {
        VStack(spacing: 5) {
            CanView(drink: drink)
                .frame(height: 90)
            Text(drink.rarity.rawValue)
                .font(.caption2.weight(.black))
                .foregroundStyle(drink.rarity.color)
            Text(drink.name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct GachaBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.12).ignoresSafeArea()
            Image("HeroArtwork")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.32)
            LinearGradient(colors: [.black.opacity(0.18), .black.opacity(0.86)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }
}

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
        overlay(ShakeDetector(onShake: action).allowsHitTesting(false))
    }
}

#Preview {
    ContentView()
}
