import Foundation
import Observation

@Observable
final class Collection {
    private let key = "collected_drink_ids"
    var collectedIDs: Set<Int> = []

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            collectedIDs = ids
        }
    }

    var count: Int { collectedIDs.count }
    var total: Int { DrinkGenerator.totalCount }
    var progress: Double { Double(count) / Double(total) }

    func add(_ drink: Drink) {
        collectedIDs.insert(drink.id)
        save()
    }

    func has(_ id: Int) -> Bool {
        collectedIDs.contains(id)
    }

    var collectedDrinks: [Drink] {
        collectedIDs.sorted().map { DrinkGenerator.drink(for: $0) }
    }

    var rarityBreakdown: [(Rarity, Int)] {
        var counts: [Rarity: Int] = [:]
        for id in collectedIDs {
            let drink = DrinkGenerator.drink(for: id)
            counts[drink.rarity, default: 0] += 1
        }
        return Rarity.allCases.map { ($0, counts[$0] ?? 0) }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(collectedIDs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
