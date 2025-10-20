import Foundation

struct CheckInRecord: Codable, Identifiable {
    var id: UUID = UUID()
    let placeID: String
    let placeNameTH: String
    let placeNameEN: String
    let meritPoints: Int
    let memberEmail: String
    var date: Date  // เปลี่ยนเป็น var เพื่อให้ admin แก้ไขได้
    let latitude: Double
    let longitude: Double
    var isEditedByAdmin: Bool = false  // เพิ่มฟิลด์เพื่อติดตามว่า admin แก้ไขหรือไม่
}

