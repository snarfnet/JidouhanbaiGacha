import SwiftUI

struct Drink: Identifiable, Equatable {
    let id: Int
    let name: String
    let flavor: String
    let category: String
    let effect: String
    let rarity: Rarity
    let color1: Color
    let color2: Color
    let description: String
    let canShape: CanShape
}

enum Rarity: String, CaseIterable {
    case n = "N"
    case r = "R"
    case sr = "SR"
    case ssr = "SSR"
    case ur = "UR"

    var color: Color {
        switch self {
        case .n: return .gray
        case .r: return .blue
        case .sr: return .purple
        case .ssr: return Color(red: 1.0, green: 0.72, blue: 0.12)
        case .ur: return Color(red: 1.0, green: 0.18, blue: 0.42)
        }
    }

    var stars: Int {
        switch self {
        case .n: return 1
        case .r: return 2
        case .sr: return 3
        case .ssr: return 4
        case .ur: return 5
        }
    }
}

enum CanShape: String, CaseIterable {
    case tall = "ロング缶"
    case short = "ショート缶"
    case bottle = "ボトル缶"
    case pet = "ペットボトル"
    case pack = "紙パック"
    case pouch = "パウチ"
}

enum DrinkGenerator {
    private static let prefixes = [
        "超", "極", "メガ", "ギガ", "幻の", "夜明けの", "秘密の", "未来の",
        "王様の", "深夜の", "初代", "復刻", "プレミアム", "ドラマチック"
    ]

    private static let bases = [
        "コーラ", "サイダー", "ラムネ", "緑茶", "抹茶ラテ", "コーヒー",
        "カフェオレ", "オレンジジュース", "りんごジュース", "ミルク",
        "エナジードリンク", "レモネード", "スムージー", "ゼリードリンク"
    ]

    private static let flavors = [
        "いちご", "メロン", "ぶどう", "マスカット", "レモン", "ライム",
        "桃", "マンゴー", "バナナ", "キウイ", "ブルーベリー", "チェリー",
        "キャラメル", "チョコ", "はちみつ", "ミント", "ラベンダー",
        "わさび", "塩", "しょうゆ", "カレー", "たこ焼き"
    ]

    private static let effects = [
        "シュワシュワ", "キラキラ", "とろとろ", "ぷちぷち", "ひんやり",
        "あつあつ", "もちもち", "すっきり", "まったり", "パチパチ"
    ]

    private static let descriptions = [
        "一口でテンションが上がる限定フレーバー。",
        "なぜかまた飲みたくなる不思議な味。",
        "開発チームが最後まで悩んだ自信作。",
        "自販機の奥から出てきたレアな一本。",
        "見た目より飲みやすい、意外な組み合わせ。",
        "深夜に飲むと妙においしい味。",
        "コレクションに残したくなるデザイン。",
        "売り切れ前に引けたら少しうれしい一本。"
    ]

    private static let colors: [(Color, Color)] = [
        (.red, .pink),
        (.blue, .cyan),
        (.green, .mint),
        (.yellow, .orange),
        (.purple, .indigo),
        (.orange, .red),
        (.teal, .blue),
        (.white, .gray),
        (.brown, .black),
        (.pink, .purple)
    ]

    static let totalCount = 10000

    static func drink(for id: Int) -> Drink {
        var seed = UInt64(id &* 2654435761)
        func next(_ max: Int) -> Int {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Int((seed >> 33) % UInt64(max))
        }

        let prefix = prefixes[next(prefixes.count)]
        let base = bases[next(bases.count)]
        let flavor = flavors[next(flavors.count)]
        let effect = effects[next(effects.count)]
        let desc = descriptions[next(descriptions.count)]
        let colorPair = colors[next(colors.count)]
        let shape = CanShape.allCases[next(CanShape.allCases.count)]

        let rarityRoll = next(100)
        let rarity: Rarity
        if rarityRoll < 1 { rarity = .ur }
        else if rarityRoll < 5 { rarity = .ssr }
        else if rarityRoll < 15 { rarity = .sr }
        else if rarityRoll < 40 { rarity = .r }
        else { rarity = .n }

        return Drink(
            id: id,
            name: "\(prefix)\(flavor)\(base)",
            flavor: flavor,
            category: base,
            effect: effect,
            rarity: rarity,
            color1: colorPair.0,
            color2: colorPair.1,
            description: "\(effect)な\(flavor)味。\(desc)",
            canShape: shape
        )
    }

    static func randomDrink() -> Drink {
        drink(for: Int.random(in: 1...totalCount))
    }
}
