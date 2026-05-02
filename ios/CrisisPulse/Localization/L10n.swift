//
//  L10n.swift
//  CrisisPulse
//
//  Bilingual (EN/ZH) string helper. Uses an in-code dictionary so the app
//  can switch language at runtime without re-launching, mirroring the web's
//  language toggle. For future expansion, migrate to .strings catalogs.
//

import Foundation

enum L10n {
    /// Resolve a key to the active language from AppState.language.
    static func tr(_ key: String, lang: String) -> String {
        let lower = lang.lowercased()
        let isZH = lower.hasPrefix("zh")
        let table = isZH ? zh : en
        return table[key] ?? en[key] ?? key
    }

    static let en: [String: String] = [
        // Tabs
        "tab.map": "Map",
        "tab.prep": "Prepare",
        "tab.settings": "Settings",
        // Map page
        "map.title": "Crisis Pulse",
        "map.subtitle": "Live Global Conflict Tracker",
        "map.live": "● LIVE",
        "map.legend.extreme": "Extreme",
        "map.legend.high": "High",
        "map.legend.medium": "Medium",
        "map.legend.low": "Low",
        "map.refresh": "Refresh",
        "map.lastUpdated": "Updated %@",
        "map.locate": "Use my location",
        "map.openCalc": "Enter Supply Calculator →",
        "map.riskAt": "Risk at your location",
        "map.relativelySafe": "Relatively safe — still recommend 2–4 weeks essentials",
        "map.mediumRisk": "Medium risk — recommend 1–3 months basic supply",
        "map.highRisk": "High risk — recommend 3–6 months, prioritize water and grain",
        "map.extremeRisk": "Extreme risk zone — strongly recommend 6+ months supply",
        // News panel
        "news.title": "Today's Key Developments",
        "news.topStory": "Today's Top Story",
        "news.alsoTracking": "Also tracking today",
        "news.articles": "articles in 48h",
        "news.badge.breaking": "BREAKING",
        "news.badge.escalating": "ESCALATING",
        "news.badge.highAttention": "HIGH ATTENTION",
        "news.empty": "No top stories yet — check back after the next daily update.",
        // Conflict detail
        "detail.intensityLabel": "Intensity",
        "detail.sourcesTitle": "Authoritative Sources",
        "detail.openSource": "Open ↗",
        "detail.shareSheet": "Share",
        "detail.newBadge": "NEW",
        // Calculator
        "calc.title": "Emergency Supply Calculator",
        "calc.step.location": "1. Where are you?",
        "calc.step.housing": "2. What kind of home?",
        "calc.step.household": "3. Who lives with you?",
        "calc.step.duration": "4. How long do you want to be prepared for?",
        "calc.country.placeholder": "Country",
        "calc.adults": "Adults",
        "calc.children": "Children",
        "calc.infants": "Has infants under 2",
        "calc.pets": "Has pets",
        "calc.medical": "Special medical needs",
        "calc.months": "%d months",
        "calc.generate": "Generate My Supply List →",
        "calc.result.title": "Your Personalized Supply List",
        "calc.result.tier.red": "Critical (0–72 hours)",
        "calc.result.tier.amber": "Sustaining (1 week+)",
        "calc.result.tier.blue": "Long-term (1 month+)",
        "calc.result.note": "Quantities scale with household size and prep duration. This is guidance, not professional advice.",
        "calc.result.share": "Share Plan",
        "calc.result.email": "Email me this plan",
        "calc.back": "Back to Map",
        // Settings
        "settings.title": "Settings",
        "settings.language": "Language",
        "settings.lang.en": "English",
        "settings.lang.zh": "中文",
        "settings.notifications": "Notifications",
        "settings.notifyEscalation": "Alert me on conflict escalations",
        "settings.subscribe.title": "Email Brief",
        "settings.subscribe.desc": "Get the daily Top-5 conflicts brief, plus emergency escalation alerts.",
        "settings.subscribe.email": "Your email address",
        "settings.subscribe.button": "Subscribe",
        "settings.subscribe.subscribing": "Subscribing…",
        "settings.subscribe.success": "You're subscribed. Check your inbox.",
        "settings.subscribe.alreadySubscribed": "You're already subscribed.",
        "settings.subscribe.error": "Subscribe failed. Try again later.",
        "settings.about": "About",
        "settings.about.line1": "Crisis Pulse · Beta 0.2",
        "settings.about.line2": "Free · Open source · No tracking",
        "settings.about.web": "crisispulse.org",
        // Generic
        "common.cancel": "Cancel",
        "common.done": "Done",
        "common.error": "Something went wrong",
    ]

    static let zh: [String: String] = [
        // Tabs
        "tab.map": "地图",
        "tab.prep": "备储",
        "tab.settings": "设置",
        // Map page
        "map.title": "危机脉搏",
        "map.subtitle": "全球冲突实时追踪",
        "map.live": "● 实时",
        "map.legend.extreme": "极高",
        "map.legend.high": "高",
        "map.legend.medium": "中",
        "map.legend.low": "低",
        "map.refresh": "刷新",
        "map.lastUpdated": "更新于 %@",
        "map.locate": "定位我的位置",
        "map.openCalc": "进入应急储备计算器 →",
        "map.riskAt": "您所在位置的风险指数",
        "map.relativelySafe": "相对安全 — 仍建议保持 2-4 周基本应急物资",
        "map.mediumRisk": "中等风险 — 建议 1-3 个月基础物资储备",
        "map.highRisk": "高风险 — 建议 3-6 个月物资，优先水和主粮",
        "map.extremeRisk": "极高风险 — 强烈建议 6 个月以上储备",
        // News panel
        "news.title": "今日重要动态",
        "news.topStory": "今日全球头条",
        "news.alsoTracking": "今日其他动态",
        "news.articles": "篇报道（48h内）",
        "news.badge.breaking": "突发",
        "news.badge.escalating": "局势升级",
        "news.badge.highAttention": "高度关注",
        "news.empty": "暂无头条动态 — 下次日更后再回来看看。",
        // Conflict detail
        "detail.intensityLabel": "强度",
        "detail.sourcesTitle": "权威信源",
        "detail.openSource": "打开 ↗",
        "detail.shareSheet": "分享",
        "detail.newBadge": "新增",
        // Calculator
        "calc.title": "应急储备计算器",
        "calc.step.location": "1. 您在哪里？",
        "calc.step.housing": "2. 居住类型？",
        "calc.step.household": "3. 家庭成员？",
        "calc.step.duration": "4. 备储时长？",
        "calc.country.placeholder": "国家/地区",
        "calc.adults": "成人",
        "calc.children": "儿童",
        "calc.infants": "有 2 岁以下婴幼儿",
        "calc.pets": "有宠物",
        "calc.medical": "特殊医疗需求",
        "calc.months": "%d 个月",
        "calc.generate": "生成我的备储清单 →",
        "calc.result.title": "您的个性化备储清单",
        "calc.result.tier.red": "紧急（0–72 小时）",
        "calc.result.tier.amber": "持续（1 周以上）",
        "calc.result.tier.blue": "长期（1 个月以上）",
        "calc.result.note": "数量会根据家庭人数和备储时长自动缩放。这是参考建议，不构成专业意见。",
        "calc.result.share": "分享方案",
        "calc.result.email": "把清单发到我邮箱",
        "calc.back": "返回地图",
        // Settings
        "settings.title": "设置",
        "settings.language": "语言",
        "settings.lang.en": "English",
        "settings.lang.zh": "中文",
        "settings.notifications": "通知",
        "settings.notifyEscalation": "冲突升级时提醒我",
        "settings.subscribe.title": "邮件简报",
        "settings.subscribe.desc": "每日获取 Top 5 冲突简报和紧急升级警报。",
        "settings.subscribe.email": "您的邮箱",
        "settings.subscribe.button": "订阅",
        "settings.subscribe.subscribing": "订阅中…",
        "settings.subscribe.success": "已订阅。请查看您的邮箱。",
        "settings.subscribe.alreadySubscribed": "您已经订阅过了。",
        "settings.subscribe.error": "订阅失败，请稍后重试。",
        "settings.about": "关于",
        "settings.about.line1": "Crisis Pulse · Beta 0.2",
        "settings.about.line2": "免费 · 开源 · 不收集数据",
        "settings.about.web": "crisispulse.org",
        // Generic
        "common.cancel": "取消",
        "common.done": "完成",
        "common.error": "出错了",
    ]
}

/// Convenience accessor used in views: T("map.title", lang)
func T(_ key: String, _ lang: String) -> String {
    L10n.tr(key, lang: lang)
}
