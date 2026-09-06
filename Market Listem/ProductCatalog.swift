import Foundation

enum ProductCatalog {
    struct Suggestion: Identifiable {
        let name: String
        let emoji: String
        var id: String { name }
    }

    static let quickSuggestions = [
        Suggestion(name: "Süt", emoji: "🥛"), Suggestion(name: "Yumurta", emoji: "🥚"),
        Suggestion(name: "Ekmek", emoji: "🍞"), Suggestion(name: "Kahve", emoji: "☕️"),
        Suggestion(name: "Tuvalet Kağıdı", emoji: "🧻"), Suggestion(name: "Şampuan", emoji: "🧴")
    ]

    private static let categories: [ProductCategory: [String]] = [
        .produce: ["elma", "armut", "muz", "portakal", "mandalina", "limon", "çilek", "üzüm", "avokado", "domates", "salatalık", "biber", "patates", "soğan", "sarımsak", "havuç", "kabak", "patlıcan", "marul", "roka", "maydanoz"],
        .dairy: ["süt", "yoğurt", "ayran", "kefir", "peynir", "kaşar", "labne", "tereyağı", "krema"],
        .protein: ["yumurta", "tavuk", "et", "balık", "kıyma", "sucuk", "salam", "ton balığı"],
        .bakery: ["ekmek", "simit", "poğaça", "lavaş", "tortilla", "hamburger ekmeği"],
        .pantry: ["kahve", "çay", "makarna", "erişte", "pirinç", "bulgur", "un", "şeker", "tuz", "zeytinyağı", "ayçiçek yağı", "salça", "mercimek", "nohut", "fasulye", "yulaf", "mısır gevreği"],
        .beverages: ["su", "maden suyu", "soda", "meyve suyu", "kola", "gazoz", "limonata"],
        .snacks: ["çikolata", "bisküvi", "cips", "kraker", "kuruyemiş", "dondurma", "gofret"],
        .cleaning: ["deterjan", "çamaşır deterjanı", "bulaşık deterjanı", "çamaşır suyu", "yumuşatıcı", "bulaşık tableti", "yüzey temizleyici", "sünger", "çöp poşeti"],
        .personalCare: ["şampuan", "saç kremi", "duş jeli", "sabun", "diş macunu", "diş fırçası", "deodorant", "tıraş köpüğü", "tuvalet kağıdı"],
        .household: ["peçete", "kağıt havlu", "ıslak mendil", "folyo", "streç film", "pişirme kağıdı", "saklama poşeti", "pil", "ampul"]
    ]

    private static let productEmojis: [String: String] = [
        "süt": "🥛", "yoğurt": "🥣", "ayran": "🥛", "kefir": "🥛", "peynir": "🧀", "kaşar": "🧀", "tereyağı": "🧈",
        "yumurta": "🥚", "tavuk": "🍗", "et": "🥩", "kıyma": "🥩", "balık": "🐟", "ton balığı": "🐟", "sucuk": "🌭",
        "ekmek": "🍞", "simit": "🥯", "poğaça": "🥐", "lavaş": "🫓", "tortilla": "🫓",
        "elma": "🍎", "armut": "🍐", "muz": "🍌", "portakal": "🍊", "mandalina": "🍊", "limon": "🍋", "çilek": "🍓", "üzüm": "🍇", "avokado": "🥑",
        "domates": "🍅", "salatalık": "🥒", "biber": "🫑", "patates": "🥔", "soğan": "🧅", "sarımsak": "🧄", "havuç": "🥕", "patlıcan": "🍆", "marul": "🥬",
        "kahve": "☕️", "çay": "🫖", "makarna": "🍝", "pirinç": "🍚", "un": "🌾", "şeker": "🧂", "tuz": "🧂", "zeytinyağı": "🫒", "yulaf": "🌾",
        "su": "💧", "maden suyu": "🫧", "soda": "🫧", "meyve suyu": "🧃", "kola": "🥤", "limonata": "🍋",
        "çikolata": "🍫", "bisküvi": "🍪", "cips": "🥔", "kraker": "🍘", "kuruyemiş": "🥜", "dondurma": "🍦",
        "deterjan": "🧺", "çamaşır deterjanı": "🧺", "bulaşık deterjanı": "🧽", "çamaşır suyu": "🧴", "sünger": "🧽", "çöp poşeti": "🗑️",
        "şampuan": "🧴", "saç kremi": "🧴", "duş jeli": "🧴", "sabun": "🧼", "diş macunu": "🪥", "diş fırçası": "🪥", "deodorant": "🧴", "tuvalet kağıdı": "🧻",
        "peçete": "🧻", "kağıt havlu": "🧻", "ıslak mendil": "🧻", "folyo": "🧻", "pil": "🔋", "ampul": "💡"
    ]

    private static let categoryEmojis: [ProductCategory: String] = [
        .produce: "🥬", .dairy: "🧀", .protein: "🍗", .bakery: "🥖", .pantry: "🫙",
        .beverages: "🥤", .snacks: "🍿", .cleaning: "🧽", .personalCare: "🧴",
        .household: "🏠", .other: "🛒"
    ]

    private static let productSymbols: [String: String] = [
        "süt": "waterbottle.fill", "ayran": "waterbottle.fill", "kefir": "waterbottle.fill",
        "peynir": "square.stack.3d.up.fill", "kaşar": "square.stack.3d.up.fill", "tereyağı": "shippingbox.fill",
        "yumurta": "oval.portrait.fill", "tavuk": "bird.fill", "balık": "fish.fill", "ton balığı": "fish.fill",
        "ekmek": "birthday.cake.fill", "simit": "circle.dotted", "poğaça": "birthday.cake.fill",
        "kahve": "cup.and.saucer.fill", "çay": "cup.and.saucer.fill", "makarna": "takeoutbag.and.cup.and.straw.fill",
        "su": "drop.fill", "maden suyu": "bubbles.and.sparkles.fill", "soda": "bubbles.and.sparkles.fill",
        "meyve suyu": "takeoutbag.and.cup.and.straw.fill", "kola": "cup.and.heat.waves.fill",
        "deterjan": "sparkles", "çamaşır deterjanı": "washer.fill", "bulaşık deterjanı": "sink.fill",
        "şampuan": "shower.handheld.fill", "duş jeli": "shower.handheld.fill", "sabun": "bubbles.and.sparkles.fill",
        "diş macunu": "mouth.fill", "diş fırçası": "mouth.fill", "tuvalet kağıdı": "toilet.fill",
        "pil": "battery.100percent", "ampul": "lightbulb.fill"
    ]

    private static let productAssets: [String: String] = [
        "süt": "ProductMilk",
        "yumurta": "ProductEgg",
        "ekmek": "ProductBread",
        "kahve": "ProductCoffee",
        "tuvalet kağıdı": "ProductToiletPaper",
        "şampuan": "ProductShampoo"
    ]

    static func normalize(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "tr_TR"))
            .lowercased(with: Locale(identifier: "tr_TR"))
    }

    static func category(for name: String) -> ProductCategory {
        let candidate = normalize(name)
        let aliases = categories.flatMap { category, names in
            names.map { (category, normalize($0)) }
        }
        return aliases
            .filter { _, alias in
                candidate == alias || candidate.hasPrefix(alias + " ") || candidate.hasSuffix(" " + alias)
            }
            .max { $0.1.count < $1.1.count }?
            .0 ?? .other
    }

    static func emoji(for name: String, category: ProductCategory? = nil) -> String {
        let candidate = normalize(name)
        let match = productEmojis
            .map { (normalize($0.key), $0.value) }
            .filter { alias, _ in
                candidate == alias || candidate.hasPrefix(alias + " ") || candidate.hasSuffix(" " + alias)
            }
            .max { $0.0.count < $1.0.count }

        if let match { return match.1 }
        return categoryEmojis[category ?? self.category(for: name)] ?? "🛒"
    }

    static func symbol(for name: String, category: ProductCategory? = nil) -> String {
        let candidate = normalize(name)
        let match = productSymbols
            .map { (normalize($0.key), $0.value) }
            .filter { alias, _ in
                candidate == alias || candidate.hasPrefix(alias + " ") || candidate.hasSuffix(" " + alias)
            }
            .max { $0.0.count < $1.0.count }

        if let match { return match.1 }
        return (category ?? self.category(for: name)).symbol
    }

    static func assetName(for name: String) -> String? {
        let candidate = normalize(name)
        return productAssets
            .map { (normalize($0.key), $0.value) }
            .filter { alias, _ in
                candidate == alias || candidate.hasPrefix(alias + " ") || candidate.hasSuffix(" " + alias)
            }
            .max { $0.0.count < $1.0.count }?
            .1
    }
}
