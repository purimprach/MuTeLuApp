import Foundation

// Struct สำหรับเก็บผลลัพธ์การคำนวณ (เหมือนเดิม)
struct NILR_Score: Identifiable {
    let id: UUID
    let place: SacredPlace
    let score: Double
}

class NILR_Recommender {
    
    private let members: [Member]
    private let places: [SacredPlace]
    private let activities: [ActivityRecord]
    
    // Map เพื่อให้เข้าถึง index ของ place ได้เร็วขึ้น
    private var placeIndexMap: [UUID: Int] = [:]
    
    init(members: [Member], places: [SacredPlace], activities: [ActivityRecord]) {
        self.members = members
        self.places = places
        self.activities = activities
        
        // สร้าง map ตอน init
        for (index, place) in places.enumerated() {
            placeIndexMap[place.id] = index
        }
    }
    
    // ฟังก์ชันหลักสำหรับเริ่มการคำนวณ ISF, ISP (เปลี่ยนชื่อเล็กน้อย)
    func calculateISFAndISP() -> (isf: [NILR_Score], isp: [NILR_Score]) {
        let interactionMatrix = createInteractionMatrix()
        let isfScores = calculateISF(matrix: interactionMatrix)
        let ispScores = calculateISP(matrix: interactionMatrix)
        return (isf: isfScores, isp: ispScores)
    }
    
    // --- 👇 [เพิ่ม] ฟังก์ชันคำนวณ IL Ranking ---
    /// คำนวณอันดับ IL โดยใช้ Pairwise Ranking Algorithm จากคะแนน ISF และ ISP
    /// - Parameters:
    ///   - isfScores: Array ของ NILR_Score ที่เรียงตาม ISF (คะแนนสูงสุดไปต่ำสุด)
    ///   - ispScores: Array ของ NILR_Score ที่เรียงตาม ISP (คะแนนสูงสุดไปต่ำสุด)
    /// - Returns: Array ของ SacredPlace ที่เรียงลำดับตาม IL
    func calculateILRanking(isfScores: [NILR_Score], ispScores: [NILR_Score]) -> [SacredPlace] {
        guard !places.isEmpty else { return [] }
        
        // สร้าง Dictionary เพื่อให้เข้าถึงคะแนนได้ง่าย O(1)
        // [PlaceID: Score]
        let isfScoreMap = Dictionary(uniqueKeysWithValues: isfScores.map { ($0.id, $0.score) })
        let ispScoreMap = Dictionary(uniqueKeysWithValues: ispScores.map { ($0.id, $0.score) })
        
        var orderedPlaces: [SacredPlace] = []
        var remainingPlaceIDs = Set(places.map { $0.id }) // ใช้ Set เพื่อให้ลบได้เร็ว O(1)
        
        // ทำซ้ำจนกว่าจะไม่มีสถานที่เหลือ
        while !remainingPlaceIDs.isEmpty {
            // หา ID ของสถานที่ที่มีคะแนนสูงสุดในแต่ละลิสต์ (เฉพาะที่ยังเหลือ)
            // ใช้ max(by:) กับ remainingPlaceIDs เพื่อหาค่าสูงสุด
            let topISF_ID = remainingPlaceIDs.max { (id1, id2) -> Bool in
                (isfScoreMap[id1] ?? -Double.infinity) < (isfScoreMap[id2] ?? -Double.infinity)
            }
            let topISP_ID = remainingPlaceIDs.max { (id1, id2) -> Bool in
                (ispScoreMap[id1] ?? -Double.infinity) < (ispScoreMap[id2] ?? -Double.infinity)
            }
            
            guard let aID = topISF_ID, let bID = topISP_ID else {
                // กรณีผิดพลาด: ไม่ควรเกิดขึ้นถ้า remainingPlaceIDs ไม่ว่าง
                print("⚠️ Error finding top ISF/ISP ID, breaking loop.")
                break
            }
            
            // ดึงคะแนนของตัว top
            let scoreA_ISF = isfScoreMap[aID] ?? -Double.infinity
            let scoreB_ISP = ispScoreMap[bID] ?? -Double.infinity
            
            if aID == bID {
                // กรณีที่ 1: สถานที่เดียวกันได้คะแนนสูงสุดทั้ง ISF และ ISP
                if let place = places.first(where: { $0.id == aID }) {
                    orderedPlaces.append(place)
                }
                remainingPlaceIDs.remove(aID)
            } else {
                // กรณีที่ 2: สถานที่ต่างกัน
                let placeA = places.first { $0.id == aID }
                let placeB = places.first { $0.id == bID }
                
                guard let pA = placeA, let pB = placeB else {
                    print("⚠️ Error finding place objects for IDs \(aID) or \(bID), skipping.")
                    // ลบ ID ที่หาไม่เจอออก เพื่อไม่ให้วนซ้ำ
                    remainingPlaceIDs.remove(aID)
                    remainingPlaceIDs.remove(bID)
                    continue
                }
                
                if scoreA_ISF >= scoreB_ISP {
                    // ถ้า ISF สูงกว่าหรือเท่ากับ ISP -> เอา A ก่อน B
                    orderedPlaces.append(pA)
                    orderedPlaces.append(pB)
                } else {
                    // ถ้า ISP สูงกว่า ISF -> เอา B ก่อน A
                    orderedPlaces.append(pB)
                    orderedPlaces.append(pA)
                }
                // ลบทั้งคู่ออกจาก Set
                remainingPlaceIDs.remove(aID)
                remainingPlaceIDs.remove(bID)
            }
        }
        
        return orderedPlaces
    }
    // --- 👆 สิ้นสุดฟังก์ชัน IL Ranking ---
    
    
    // (ฟังก์ชัน createInteractionMatrix, calculateISF, calculateISP, และ helpers เหมือนเดิม)
    // ... [ใส่โค้ดส่วนนั้นที่นี่] ...
    // สร้างเมทริกซ์จำลองการมีอยู่ของข้อมูล (1 คือเคยไป, 0 คือไม่เคย)
    private func createInteractionMatrix() -> [[Double]] {
        var matrix = Array(repeating: Array(repeating: 0.0, count: places.count), count: members.count)
        
        for (userIndex, member) in members.enumerated() {
            for (placeIndex, place) in places.enumerated() {
                // เช็คว่า user คนนี้เคย check-in ที่สถานที่นี้หรือไม่
                let hasCheckedIn = activities.contains {
                    $0.memberEmail.lowercased() == member.email.lowercased() &&
                    $0.placeID == place.id.uuidString &&
                    $0.type == .checkIn
                }
                if hasCheckedIn {
                    matrix[userIndex][placeIndex] = 1.0
                }
            }
        }
        return matrix
    }
    
    // คำนวณ ISF (Iterative Scoring Function - ตามความถี่)
    private func calculateISF(matrix: [[Double]]) -> [NILR_Score] {
        guard !members.isEmpty, !places.isEmpty else { return [] }
        
        var userScores = Array(repeating: 1.0, count: members.count)
        var locationScores = Array(repeating: 0.0, count: places.count)
        
        for _ in 0..<3 { // ทำซ้ำ 3 รอบตามสคริปต์ Python
            // อัปเดตคะแนนสถานที่: l_score = u_score • R
            locationScores = dot(vector: userScores, matrix: matrix)
            
            // Normalize คะแนนสถานที่
            let normL = normalize(vector: locationScores)
            
            // อัปเดตคะแนนผู้ใช้: u_score = R • l_score
            userScores = dot(matrix: matrix, vector: normL)
            
            // Normalize คะแนนผู้ใช้
            userScores = normalize(vector: userScores)
        }
        
        // จัดเรียงผลลัพธ์
        let finalScores = normalize(vector: locationScores)
        var results: [NILR_Score] = []
        for (index, place) in places.enumerated() {
            results.append(NILR_Score(id: place.id, place: place, score: finalScores[index]))
        }
        
        return results.sorted { $0.score > $1.score }
    }
    
    // คำนวณ ISP (Iterative Scoring Preference - ตามความชอบ/กลับมาซ้ำ)
    private func calculateISP(matrix: [[Double]]) -> [NILR_Score] {
        guard !members.isEmpty, !places.isEmpty else { return [] }
        
        // prefU: ความชอบของผู้ใช้ (นับจำนวนสถานที่ที่ไปซ้ำ)
        let prefU = members.map { member in
            Double(Set(activities.filter { $0.memberEmail.lowercased() == member.email.lowercased() && $0.type == .checkIn }.map { $0.placeID }).count)
        }
        
        // prefL: ความนิยมของสถานที่ (นับจำนวนผู้ใช้ที่กลับมาซ้ำ)
        let prefL = places.map { place in
            Double(Set(activities.filter { $0.placeID == place.id.uuidString && $0.type == .checkIn }.map { $0.memberEmail }).count)
        }
        
        var userScores = Array(repeating: 1.0, count: members.count)
        var locationScores = Array(repeating: 0.0, count: places.count)
        
        for _ in 0..<3 {
            let weightedUserScores = zip(userScores, prefU).map(*)
            locationScores = dot(vector: Array(weightedUserScores), matrix: matrix)
            let normL = normalize(vector: locationScores)
            
            let weightedLocationScores = zip(normL, prefL).map(*)
            userScores = dot(matrix: matrix, vector: Array(weightedLocationScores))
            userScores = normalize(vector: userScores)
        }
        
        let finalScores = normalize(vector: locationScores)
        var results: [NILR_Score] = []
        for (index, place) in places.enumerated() {
            results.append(NILR_Score(id: place.id, place: place, score: finalScores[index]))
        }
        
        return results.sorted { $0.score > $1.score }
    }
    
    // --- Helper functions for matrix multiplication ---
    private func dot(vector: [Double], matrix: [[Double]]) -> [Double] {
        guard !matrix.isEmpty, !vector.isEmpty, matrix.count == vector.count else { return [] }
        var result = Array(repeating: 0.0, count: matrix[0].count)
        for j in 0..<matrix[0].count {
            for i in 0..<vector.count {
                result[j] += vector[i] * matrix[i][j]
            }
        }
        return result
    }
    
    private func dot(matrix: [[Double]], vector: [Double]) -> [Double] {
        guard !matrix.isEmpty, !vector.isEmpty, matrix[0].count == vector.count else { return [] }
        var result = Array(repeating: 0.0, count: matrix.count)
        for i in 0..<matrix.count {
            for j in 0..<vector.count {
                result[i] += matrix[i][j] * vector[j]
            }
        }
        return result
    }
    
    private func normalize(vector: [Double]) -> [Double] {
        let norm = sqrt(vector.map { $0 * $0 }.reduce(0, +))
        // เพิ่มการตรวจสอบ norm > 0 เล็กน้อย เพื่อป้องกันการหารด้วยศูนย์
        return norm > 1e-9 ? vector.map { $0 / norm } : vector
    }
}
