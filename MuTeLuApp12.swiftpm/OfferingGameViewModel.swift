import Foundation
import SwiftUI

class OfferingGameViewModel: ObservableObject {
    @Published var basket: [OfferingItem] = []
    @Published var currentLevel = 0
    @Published var isGameFinished = false
    
    var currentOfferingLevel: OfferingLevel {
        offeringLevels[currentLevel]
    }
    
    var usedBudget: Int {
        basket.reduce(0) { $0 + $1.price }
    }
    
    // 👇 เพิ่ม 2 ตัวแปรนี้
    var isOverBudget: Bool {
        usedBudget > currentOfferingLevel.budget
    }
    
    func addItem(_ item: OfferingItem) {
        basket.append(item)
    }
    
    // 👇 เพิ่มฟังก์ชันนี้
    func removeItem(_ item: OfferingItem) {
        if let index = basket.firstIndex(where: { $0.id == item.id }) {
            basket.remove(at: index)
        }
    }
    
    func resetBasket() {
        basket.removeAll()
    }
    
    // 👇 แก้ไขฟังก์ชันนี้ให้คืนค่าทั้งผลลัพธ์และข้อความ Error
    func checkResult() -> (success: Bool, message: (th: String, en: String)) {
        if isOverBudget {
            return (false, (th: "คุณใช้งบประมาณเกินกำหนด", en: "You are over budget"))
        }
        
        let appropriateCount = basket.filter { $0.isAppropriate }.count
        if appropriateCount < currentOfferingLevel.minAppropriateCount {
            return (false, (th: "ของที่เหมาะสมมีไม่ครบตามกำหนด", en: "Not enough appropriate items"))
        }
        
        if basket.contains(where: { !$0.isAppropriate }) {
            return (false, (th: "มีของบางชิ้นที่ไม่เหมาะสมอยู่ในตะกร้า", en: "There is an inappropriate item in the basket"))
        }
        
        return (true, (th: "", en: ""))
    }
    
    func goToNextLevel() {
        if currentLevel + 1 < offeringLevels.count {
            currentLevel += 1
            resetBasket()
        } else {
            // ด่านสุดท้ายแล้ว
            isGameFinished = true
        }
    }
}
