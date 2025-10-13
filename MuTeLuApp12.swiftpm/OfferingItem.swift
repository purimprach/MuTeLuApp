import Foundation

struct OfferingItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let emoji: String // 👈 เพิ่มบรรทัดนี้
    let price: Int
    let isAppropriate: Bool
}

// อัปเดตข้อมูลตัวอย่างให้มี emoji
let sampleOfferingItems: [OfferingItem] = [
    OfferingItem(name: "สบู่", emoji: "🧼", price: 20, isAppropriate: true),
    OfferingItem(name: "ยาสีฟัน", emoji: "🪥", price: 25, isAppropriate: true),
    OfferingItem(name: "บุหรี่", emoji: "🚬", price: 45, isAppropriate: false),
    OfferingItem(name: "แชมพู", emoji: "🧴", price: 30, isAppropriate: true),
    OfferingItem(name: "เบียร์", emoji: "🍺", price: 60, isAppropriate: false),
    OfferingItem(name: "ผ้าเช็ดตัว", emoji: "🧖", price: 50, isAppropriate: true),
    OfferingItem(name: "น้ำเปล่า", emoji: "💧", price: 10, isAppropriate: true),
    OfferingItem(name: "ยาแก้ปวด", emoji: "💊", price: 15, isAppropriate: true),
]

