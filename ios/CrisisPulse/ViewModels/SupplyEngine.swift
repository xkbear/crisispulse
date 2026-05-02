//
//  SupplyEngine.swift
//  CrisisPulse
//
//  Translates a CalculatorInput into a personalized list of supply categories.
//  Mirrors the logic in the web app's calculator (vanilla JS in index.html),
//  scaled to household size and target preparedness duration.
//

import Foundation

enum SupplyEngine {
    static func build(from input: CalculatorInput) -> [SupplyCategory] {
        let people = max(1, input.adults + input.children)
        let months = max(1, input.months)

        // Water: 4 L per person per day → kg, but show in liters
        let waterLiters = people * 4 * 30 * months
        // Food: 2200 kcal/person/day → ~0.7 kg dry staples
        let grainKg = Int(Double(people) * 0.7 * 30 * Double(months) * 0.7)
        let cannedCount = people * 30 * months / 2 // one can / 2 days / person
        // Med, power, comm scale slower
        let medkitCount = max(1, (people / 4) + 1)

        var red: [SupplyItem] = []
        var amber: [SupplyItem] = []
        var blue: [SupplyItem] = []

        // RED — critical 0–72h
        red.append(SupplyItem(
            name: "Bottled drinking water",
            nameZh: "瓶装饮用水",
            quantity: "\(min(waterLiters, people * 4 * 3)) L",
            rationale: "4 L/person/day · 72 hours minimum",
            rationaleZh: "每人每天 4 升 · 至少 72 小时"
        ))
        red.append(SupplyItem(
            name: "First-aid kit",
            nameZh: "急救包",
            quantity: "\(medkitCount)",
            rationale: "Bandages, disinfectant, painkillers, scissors",
            rationaleZh: "绷带、消毒、止痛药、剪刀"
        ))
        red.append(SupplyItem(
            name: "Flashlight + spare batteries",
            nameZh: "手电筒 + 备用电池",
            quantity: "\(max(2, people / 2))",
            rationale: "LED preferred, hand-crank backup ideal",
            rationaleZh: "LED 优先，手摇发电更佳"
        ))
        if input.hasMedicalNeeds {
            red.append(SupplyItem(
                name: "Prescription medication buffer",
                nameZh: "处方药备储",
                quantity: "\(months) months",
                rationale: "Rotate stock and check expiry monthly",
                rationaleZh: "每月轮换并检查有效期"
            ))
        }
        if input.hasInfants {
            red.append(SupplyItem(
                name: "Infant formula + diapers",
                nameZh: "婴儿配方奶 + 纸尿裤",
                quantity: "\(months * 4) packs",
                rationale: "Match brand to baby's current intake",
                rationaleZh: "选用宝宝当前适用的品牌"
            ))
        }

        // AMBER — sustaining 1 week+
        amber.append(SupplyItem(
            name: "Total bottled water (full duration)",
            nameZh: "饮用水总量（全周期）",
            quantity: "\(waterLiters) L",
            rationale: "Include filtration backup if storage is limited",
            rationaleZh: "若储存空间有限，配净水器作为备份"
        ))
        amber.append(SupplyItem(
            name: "Canned food",
            nameZh: "罐装食品",
            quantity: "\(cannedCount) cans",
            rationale: "Mixed protein + vegetable, ring-pull lids preferred",
            rationaleZh: "蛋白和蔬菜混合，优先易拉罐"
        ))
        amber.append(SupplyItem(
            name: "Power bank (high-capacity)",
            nameZh: "大容量充电宝",
            quantity: "\(max(2, people / 2)) × 20 000 mAh+",
            rationale: "Keep at 50% charge baseline",
            rationaleZh: "平时保持 50% 电量基线"
        ))
        if input.hasPets {
            amber.append(SupplyItem(
                name: "Pet food",
                nameZh: "宠物食品",
                quantity: "\(months) months",
                rationale: "Dry food shelf-life > wet; add water plan",
                rationaleZh: "干粮保质期更长；额外预留饮水计划"
            ))
        }

        // BLUE — long-term 1 month+
        blue.append(SupplyItem(
            name: "Dry staples (rice, pasta, flour)",
            nameZh: "干主粮（米、面、粉）",
            quantity: "\(grainKg) kg",
            rationale: "Store in airtight containers, rotate every 12 months",
            rationaleZh: "密封储存，每 12 个月轮换"
        ))
        blue.append(SupplyItem(
            name: "Cooking fuel (gas / butane / charcoal)",
            nameZh: "炊事燃料（液化气/丁烷/木炭）",
            quantity: "\(months * 2) cans",
            rationale: "Store outdoors; check housing rules first",
            rationaleZh: "户外存放；先确认住宅规定"
        ))
        blue.append(SupplyItem(
            name: "Document copies + cash reserve",
            nameZh: "证件副本 + 现金储备",
            quantity: "1 set",
            rationale: "Passport, insurance, emergency contacts, ~2 weeks cash",
            rationaleZh: "护照、保险、紧急联系人、约 2 周现金"
        ))
        switch input.housing {
        case .rural:
            blue.append(SupplyItem(
                name: "Hand-crank radio",
                nameZh: "手摇收音机",
                quantity: "1",
                rationale: "Cellular fails first when grid goes down",
                rationaleZh: "电网中断时手机信号最先失效"
            ))
        case .mobile:
            blue.append(SupplyItem(
                name: "Spare fuel + tire repair kit",
                nameZh: "备用燃油 + 补胎工具",
                quantity: "Full tank + kit",
                rationale: "Mobility is your shelter — protect it",
                rationaleZh: "移动性就是您的庇护所 — 保护好它"
            ))
        default:
            break
        }

        return [
            SupplyCategory(title: "Critical", titleZh: "紧急", icon: "exclamationmark.triangle.fill", tier: .red, items: red),
            SupplyCategory(title: "Sustaining", titleZh: "持续", icon: "battery.75percent", tier: .amber, items: amber),
            SupplyCategory(title: "Long-term", titleZh: "长期", icon: "shippingbox.fill", tier: .blue, items: blue)
        ]
    }
}
