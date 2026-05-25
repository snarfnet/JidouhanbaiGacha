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
        case .ssr: return Color(red: 1.0, green: 0.7, blue: 0.0)
        case .ur: return Color(red: 1.0, green: 0.2, blue: 0.4)
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
    case tall = "缶(トール)"
    case short = "缶(ショート)"
    case bottle = "ボトル"
    case pet = "ペットボトル"
    case pack = "紙パック"
    case pouch = "パウチ"
}

enum DrinkGenerator {
    private static let prefixes = [
        "超", "極", "メガ", "ギガ", "ミニ", "裏", "闇", "光", "真",
        "新", "元祖", "伝説の", "幻の", "禁断の", "秘密の", "最強",
        "激", "鬼", "神", "魔", "天使の", "悪魔の", "皇帝の", "王様の",
        "深夜の", "朝の", "夕暮れの", "真夜中の", "黄昏の",
        "宇宙", "海底", "火山", "氷河", "砂漠の", "密林の",
        "初代", "復刻", "限定", "プレミアム", "デラックス",
        "ぷち", "どっさり", "たっぷり", "ほんのり", "がっつり",
    ]

    private static let bases = [
        "コーラ", "サイダー", "ラムネ", "ジンジャーエール", "トニック",
        "緑茶", "烏龍茶", "紅茶", "ほうじ茶", "抹茶", "ジャスミン茶",
        "コーヒー", "カフェオレ", "エスプレッソ", "カプチーノ", "モカ",
        "オレンジジュース", "りんごジュース", "ぶどうジュース", "パイナップルジュース",
        "ミルク", "ヨーグルト", "カルピス", "ココア", "甘酒",
        "エナジードリンク", "栄養ドリンク", "スポーツドリンク", "プロテインシェイク",
        "炭酸水", "ミネラルウォーター", "レモネード", "スムージー",
        "タピオカドリンク", "フラペチーノ風", "ゼリードリンク", "シェイク",
        "ビネガーソーダ", "酵素ドリンク", "豆乳", "アーモンドミルク",
        "チャイ", "ルイボスティー", "コンブチャ", "梅ジュース",
    ]

    private static let flavors = [
        "いちご", "メロン", "ぶどう", "マスカット", "レモン", "ライム",
        "桃", "マンゴー", "バナナ", "キウイ", "パッションフルーツ",
        "ブルーベリー", "ラズベリー", "チェリー", "洋梨", "柚子",
        "すだち", "みかん", "グレープフルーツ", "ライチ", "ドラゴンフルーツ",
        "バニラ", "キャラメル", "チョコレート", "抹茶", "黒糖",
        "はちみつ", "生姜", "シナモン", "ミント", "ラベンダー",
        "さくら", "バラ", "ジャスミン", "カモミール", "ハイビスカス",
        "わさび", "唐辛子", "カレー", "しょうゆ", "味噌",
        "塩", "酢", "めんつゆ", "タバスコ", "マヨネーズ",
        "たこ焼き", "焼きそば", "おでん", "ラーメン", "すき焼き",
    ]

    private static let effects = [
        "シュワシュワ", "キラキラ", "ドロドロ", "トロトロ", "プチプチ",
        "ひんやり", "あつあつ", "ピリピリ", "ふわふわ", "もちもち",
        "ネバネバ", "サラサラ", "ガツン", "スッキリ", "まったり",
        "ゴクゴク", "ジュワッ", "パチパチ", "シャリシャリ", "ぷるぷる",
        "ズドーン", "バキバキ", "グビグビ", "チビチビ", "ゴロゴロ",
    ]

    private static let descriptions = [
        "一口飲むと止まらなくなる",
        "誰が考えたのか分からない味",
        "深夜3時に最高の味わい",
        "おばあちゃんが絶句した",
        "科学の限界に挑戦した一品",
        "開発者が泣きながら作った",
        "社内テストで賛否両論",
        "二度と作れない配合ミス",
        "月面でも飲みたい味",
        "AIが設計した未来の味",
        "5秒で好きか嫌いか分かれる",
        "記憶に残るか消えるか",
        "修学旅行で買いたかった",
        "冷蔵庫の奥で見つけた気分",
        "全然売れなかったけど復活",
        "味覚テストをすり抜けた",
        "隣の県では大人気",
        "試飲会で3人だけ絶賛",
        "原価が販売価格を超えた",
        "製造工程が企業秘密",
        "飲んだ人の感想が全部違う",
        "夢に出てきそうな色",
        "自販機だけの限定販売",
        "店長の趣味で仕入れた",
        "海外では高級品扱い",
    ]

    private static let colors: [(Color, Color)] = [
        (Color(red: 1.0, green: 0.2, blue: 0.2), Color(red: 0.8, green: 0.1, blue: 0.1)),
        (Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.1, green: 0.3, blue: 0.8)),
        (Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.6, blue: 0.2)),
        (Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 0.9, green: 0.5, blue: 0.0)),
        (Color(red: 0.8, green: 0.2, blue: 0.8), Color(red: 0.5, green: 0.1, blue: 0.6)),
        (Color(red: 1.0, green: 0.5, blue: 0.3), Color(red: 0.9, green: 0.3, blue: 0.1)),
        (Color(red: 0.3, green: 0.8, blue: 0.8), Color(red: 0.1, green: 0.5, blue: 0.6)),
        (Color(red: 0.9, green: 0.9, blue: 0.9), Color(red: 0.6, green: 0.6, blue: 0.7)),
        (Color(red: 0.4, green: 0.2, blue: 0.1), Color(red: 0.2, green: 0.1, blue: 0.05)),
        (Color(red: 1.0, green: 0.4, blue: 0.6), Color(red: 0.9, green: 0.2, blue: 0.4)),
        (Color(red: 0.0, green: 0.5, blue: 0.3), Color(red: 0.0, green: 0.3, blue: 0.2)),
        (Color(red: 0.6, green: 0.4, blue: 0.8), Color(red: 0.4, green: 0.2, blue: 0.6)),
        (Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.05, green: 0.05, blue: 0.15)),
        (Color(red: 1.0, green: 1.0, blue: 0.5), Color(red: 0.9, green: 0.8, blue: 0.2)),
        (Color(red: 0.7, green: 0.9, blue: 0.3), Color(red: 0.4, green: 0.7, blue: 0.1)),
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

        let name = "\(prefix)\(flavor)\(base)"

        return Drink(
            id: id,
            name: name,
            flavor: flavor,
            category: base,
            effect: effect,
            rarity: rarity,
            color1: colorPair.0,
            color2: colorPair.1,
            description: "\(effect)な\(flavor)味。\(desc)。",
            canShape: shape
        )
    }

    static func randomDrink() -> Drink {
        drink(for: Int.random(in: 1...totalCount))
    }
}
