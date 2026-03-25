import { getStore } from "@netlify/blobs";

// Base conflict data - lat/lon/type/sources never change, only intensity and desc are dynamic
const BASE_CONFLICTS = [
  {name:"Russia-Ukraine War",lat:48.5,lon:35.5,intensity:9,type:"Full-Scale War",desc:"Largest conventional war in Europe, ongoing fifth year",
   sources:[{title:"CFR: Russia-Ukraine War",url:"https://www.cfr.org/global-conflict-tracker/conflict/conflict-ukraine"},{title:"ACLED Ukraine Data",url:"https://acleddata.com/ukraine-conflict-monitor/"},{title:"UNHCR Ukraine Emergency",url:"https://www.unhcr.org/ukraine-emergency.html"}]},
  {name:"Israel-Palestine",lat:31.5,lon:34.5,intensity:9,type:"Full-Scale War",desc:"Gaza humanitarian crisis continuing",
   sources:[{title:"CFR: Israeli-Palestinian Conflict",url:"https://www.cfr.org/global-conflict-tracker/conflict/israeli-palestinian-conflict"},{title:"OCHA: Palestine",url:"https://www.ochaopt.org/"},{title:"Al Jazeera: Gaza",url:"https://www.aljazeera.com/tag/gaza/"}]},
  {name:"US-Israel-Iran Conflict",lat:32.5,lon:53,intensity:8,type:"High Intensity",desc:"Regional escalation after February 2026 strikes",
   sources:[{title:"Crisis Group: Iran",url:"https://www.crisisgroup.org/middle-east-north-africa/gulf-and-arabian-peninsula/iran"},{title:"Reuters: Iran",url:"https://www.reuters.com/places/iran"},{title:"CFR: Iran Conflict",url:"https://www.cfr.org/global-conflict-tracker/conflict/confrontation-between-iran-and-united-states"}]},
  {name:"Yemen Civil War",lat:15.5,lon:44,intensity:7,type:"High Intensity",desc:"Houthi attacks on Red Sea shipping",
   sources:[{title:"CFR: Yemen Civil War",url:"https://www.cfr.org/global-conflict-tracker/conflict/war-yemen"},{title:"Crisis Group: Yemen",url:"https://www.crisisgroup.org/middle-east-north-africa/gulf-and-arabian-peninsula/yemen"},{title:"OCHA: Yemen",url:"https://www.unocha.org/yemen"}]},
  {name:"Sudan Civil War",lat:15.5,lon:32.5,intensity:9,type:"Full-Scale War",desc:"SAF vs RSF conflict, over 10 million displaced",
   sources:[{title:"ACLED: Sudan",url:"https://acleddata.com/knowledge-base/sudan/"},{title:"UNHCR: Sudan Emergency",url:"https://www.unhcr.org/sudan-emergency.html"},{title:"Crisis Group: Sudan",url:"https://www.crisisgroup.org/africa/horn-africa/sudan"}]},
  {name:"Myanmar Civil War",lat:19.8,lon:96.2,intensity:8,type:"High Intensity",desc:"Military junta vs multiple resistance forces",
   sources:[{title:"Crisis Group: Myanmar",url:"https://www.crisisgroup.org/asia/south-east-asia/myanmar"},{title:"CFR: Myanmar Civil War",url:"https://www.cfr.org/global-conflict-tracker/conflict/rohingya-crisis-myanmar"},{title:"BBC: Myanmar",url:"https://www.bbc.com/news/topics/c8nq32jwj8mt"}]},
  {name:"Syria Conflict",lat:35,lon:38,intensity:7,type:"High Intensity",desc:"Multiple factions ongoing",
   sources:[{title:"CFR: Syrian Civil War",url:"https://www.cfr.org/global-conflict-tracker/conflict/civil-war-syria"},{title:"OCHA: Syria",url:"https://www.unocha.org/syria"},{title:"ACLED: Syria",url:"https://acleddata.com/knowledge-base/syria/"}]},
  {name:"Lebanon Crisis",lat:33.9,lon:35.5,intensity:7,type:"High Intensity",desc:"Israel-Hezbollah conflict spillover",
   sources:[{title:"Crisis Group: Lebanon",url:"https://www.crisisgroup.org/middle-east-north-africa/east-mediterranean-mena/lebanon"},{title:"Reuters: Lebanon",url:"https://www.reuters.com/places/lebanon"}]},
  {name:"Eastern DRC Conflict",lat:-1.5,lon:29,intensity:7,type:"High Intensity",desc:"M23 militants vs government forces",
   sources:[{title:"Crisis Group: DR Congo",url:"https://www.crisisgroup.org/africa/great-lakes/democratic-republic-congo"},{title:"CFR: DRC Violence",url:"https://www.cfr.org/global-conflict-tracker/conflict/violence-democratic-republic-congo"},{title:"UNHCR: DRC",url:"https://www.unhcr.org/drc-emergency.html"}]},
  {name:"Sahel Region Crisis",lat:14,lon:-1,intensity:7,type:"High Intensity",desc:"Mali/Burkina Faso/Niger armed conflicts",
   sources:[{title:"ACLED: Sahel",url:"https://acleddata.com/knowledge-base/sahel/"},{title:"Crisis Group: Sahel",url:"https://www.crisisgroup.org/africa/sahel"},{title:"OCHA: Sahel",url:"https://www.unocha.org/sahel"}]},
  {name:"Somalia",lat:5,lon:46,intensity:6,type:"Medium Conflict",desc:"Al-Shabaab militant activity",
   sources:[{title:"CFR: Al-Shabaab in Somalia",url:"https://www.cfr.org/global-conflict-tracker/conflict/al-shabab-somalia"},{title:"Crisis Group: Somalia",url:"https://www.crisisgroup.org/africa/horn-africa/somalia"}]},
  {name:"Northern Nigeria",lat:10,lon:8,intensity:6,type:"Medium Conflict",desc:"Boko Haram remnants and herder clashes",
   sources:[{title:"CFR: Boko Haram in Nigeria",url:"https://www.cfr.org/global-conflict-tracker/conflict/boko-haram-nigeria"},{title:"Crisis Group: Nigeria",url:"https://www.crisisgroup.org/africa/west-africa/nigeria"},{title:"ACLED: Nigeria",url:"https://acleddata.com/knowledge-base/nigeria/"}]},
  {name:"Ethiopia",lat:8,lon:39,intensity:5,type:"Medium Conflict",desc:"Fragile Tigray peace, scattered conflicts",
   sources:[{title:"CFR: Ethiopia Conflict",url:"https://www.cfr.org/global-conflict-tracker/conflict/war-ethiopia"},{title:"Crisis Group: Ethiopia",url:"https://www.crisisgroup.org/africa/horn-africa/ethiopia"}]},
  {name:"Afghanistan",lat:34,lon:67,intensity:6,type:"Medium Conflict",desc:"Unstable security under Taliban",
   sources:[{title:"CFR: Afghanistan War",url:"https://www.cfr.org/global-conflict-tracker/conflict/war-afghanistan"},{title:"Crisis Group: Afghanistan",url:"https://www.crisisgroup.org/asia/south-asia/afghanistan"},{title:"OCHA: Afghanistan",url:"https://www.unocha.org/afghanistan"}]},
  {name:"Northwest Pakistan",lat:33,lon:70,intensity:5,type:"Medium Conflict",desc:"TTP militant attacks",
   sources:[{title:"Crisis Group: Pakistan",url:"https://www.crisisgroup.org/asia/south-asia/pakistan"},{title:"ACLED: Pakistan",url:"https://acleddata.com/knowledge-base/pakistan/"}]},
  {name:"Haiti",lat:19,lon:-72.3,intensity:6,type:"Medium Conflict",desc:"Gang violence and state collapse",
   sources:[{title:"Crisis Group: Haiti",url:"https://www.crisisgroup.org/latin-america-caribbean/haiti"},{title:"CFR: Haiti Instability",url:"https://www.cfr.org/global-conflict-tracker/conflict/instability-haiti"}]},
  {name:"Colombia",lat:4,lon:-74,intensity:4,type:"Low Risk",desc:"Fragile peace, armed groups in some regions",
   sources:[{title:"Crisis Group: Colombia",url:"https://www.crisisgroup.org/latin-america-caribbean/andes/colombia"},{title:"CFR: Colombia",url:"https://www.cfr.org/global-conflict-tracker/conflict/colombias-civil-conflict"}]},
  {name:"Mexico",lat:23,lon:-102,intensity:5,type:"Medium Conflict",desc:"Drug cartel violence",
   sources:[{title:"CFR: Criminal Violence in Mexico",url:"https://www.cfr.org/global-conflict-tracker/conflict/criminal-violence-mexico"},{title:"Crisis Group: Mexico",url:"https://www.crisisgroup.org/latin-america-caribbean/mexico"}]},
  {name:"Iraq",lat:33.3,lon:44.4,intensity:5,type:"Medium Conflict",desc:"ISIS remnants and militia clashes",
   sources:[{title:"CFR: Iraq Conflict",url:"https://www.cfr.org/global-conflict-tracker/conflict/political-instability-iraq"},{title:"Crisis Group: Iraq",url:"https://www.crisisgroup.org/middle-east-north-africa/gulf-and-arabian-peninsula/iraq"}]},
  {name:"Libya",lat:32.9,lon:13.2,intensity:5,type:"Medium Conflict",desc:"Divided government and militia standoff",
   sources:[{title:"CFR: Libya Civil War",url:"https://www.cfr.org/global-conflict-tracker/conflict/civil-war-libya"},{title:"Crisis Group: Libya",url:"https://www.crisisgroup.org/middle-east-north-africa/north-africa/libya"}]},
  {name:"Southern Philippines",lat:7,lon:124,intensity:4,type:"Low Risk",desc:"Mindanao armed remnants",
   sources:[{title:"Crisis Group: Philippines",url:"https://www.crisisgroup.org/asia/south-east-asia/philippines"},{title:"ACLED: Philippines",url:"https://acleddata.com/knowledge-base/philippines/"}]},
  {name:"Kashmir India-Pakistan",lat:34,lon:76,intensity:4,type:"Low Risk",desc:"Ongoing border tensions",
   sources:[{title:"CFR: India-Pakistan Conflict",url:"https://www.cfr.org/global-conflict-tracker/conflict/conflict-between-india-and-pakistan"},{title:"Crisis Group: Kashmir",url:"https://www.crisisgroup.org/asia/south-asia/kashmir"}]},
  {name:"Taiwan Strait",lat:24,lon:121,intensity:3,type:"Geopolitical Tension",desc:"Military exercises, sustained tension",
   sources:[{title:"CFR: Taiwan Strait Tensions",url:"https://www.cfr.org/global-conflict-tracker/conflict/tensions-taiwan-strait"},{title:"Reuters: Taiwan",url:"https://www.reuters.com/places/taiwan"}]},
  {name:"Korean Peninsula",lat:38,lon:127,intensity:3,type:"Geopolitical Tension",desc:"Missile tests and military standoff",
   sources:[{title:"CFR: North Korea Conflict",url:"https://www.cfr.org/global-conflict-tracker/conflict/north-korea-crisis"},{title:"Crisis Group: Korean Peninsula",url:"https://www.crisisgroup.org/asia/north-east-asia/korean-peninsula"}]},
  {name:"South China Sea",lat:12,lon:114,intensity:3,type:"Geopolitical Tension",desc:"Multiple territorial disputes",
   sources:[{title:"CFR: South China Sea Disputes",url:"https://www.cfr.org/global-conflict-tracker/conflict/territorial-disputes-south-china-sea"},{title:"Crisis Group: South China Sea",url:"https://www.crisisgroup.org/asia/south-east-asia"}]}
];

// GDELT search keywords optimized for each conflict
const SEARCH_TERMS = {
  "Russia-Ukraine War": "Ukraine war Russia military",
  "Israel-Palestine": "Gaza Israel Palestine conflict",
  "US-Israel-Iran Conflict": "Iran Israel strike military",
  "Yemen Civil War": "Yemen Houthi Red Sea",
  "Sudan Civil War": "Sudan RSF SAF war",
  "Myanmar Civil War": "Myanmar junta resistance",
  "Syria Conflict": "Syria conflict military",
  "Lebanon Crisis": "Lebanon Hezbollah crisis",
  "Eastern DRC Conflict": "Congo DRC M23 conflict",
  "Sahel Region Crisis": "Sahel Mali Burkina Faso conflict",
  "Somalia": "Somalia Al-Shabaab attack",
  "Northern Nigeria": "Nigeria Boko Haram violence",
  "Ethiopia": "Ethiopia Tigray conflict",
  "Afghanistan": "Afghanistan Taliban security",
  "Northwest Pakistan": "Pakistan TTP militant attack",
  "Haiti": "Haiti gang violence crisis",
  "Colombia": "Colombia armed group conflict",
  "Mexico": "Mexico cartel violence",
  "Iraq": "Iraq ISIS militia attack",
  "Libya": "Libya militia conflict",
  "Southern Philippines": "Philippines Mindanao militant",
  "Kashmir India-Pakistan": "Kashmir India Pakistan tension",
  "Taiwan Strait": "Taiwan China military tension",
  "Korean Peninsula": "North Korea missile military",
  "South China Sea": "South China Sea dispute military"
};

export default async () => {
  const store = getStore("conflict-data");

  // Load previous data to smooth intensity changes
  const previous = await store.get("conflicts", { type: "json" });
  const prevMap = {};
  if (previous?.conflicts) {
    previous.conflicts.forEach(c => { prevMap[c.name] = c; });
  }

  // Process one conflict against GDELT
  async function processConflict(base) {
    const query = SEARCH_TERMS[base.name] || base.name;
    const prev = prevMap[base.name];
    let articleCount = 0, avgTone = 0;
    let topHeadline = prev?.desc || base.desc;

    try {
      const url = `https://api.gdeltproject.org/api/v2/doc/doc?query=${encodeURIComponent(query)}&mode=artlist&maxrecords=20&timespan=48h&format=json&sort=datedesc`;
      const res = await fetch(url, { signal: AbortSignal.timeout(5000) });
      if (res.ok) {
        const text = await res.text();
        try {
          const data = JSON.parse(text);
          const articles = data.articles || [];
          articleCount = articles.length;
          if (articles.length > 0) {
            avgTone = articles.reduce((s, a) => s + (a.tone || 0), 0) / articles.length;
            const enArticle = articles.find(a => a.language === "English") || articles[0];
            if (enArticle?.title) {
              topHeadline = enArticle.title.length > 80 ? enArticle.title.substring(0, 77) + "..." : enArticle.title;
            }
          }
        } catch (_) {}
      }
    } catch (e) {
      console.warn(`GDELT failed for ${base.name}: ${e.message}`);
    }

    let delta = articleCount >= 30 ? 1.0 : articleCount >= 15 ? 0.5 : articleCount >= 5 ? 0 : -0.5;
    if (avgTone < -5) delta += 0.5;
    const prevIntensity = prev?.intensity || base.intensity;
    let newIntensity = Math.round(Math.min(10, Math.max(1, prevIntensity + delta * 0.3)) * 10) / 10;

    return { ...base, intensity: newIntensity, desc: topHeadline };
  }

  // Process in batches of 5 for speed (avoid sequential bottleneck)
  const updated = [];
  for (let i = 0; i < BASE_CONFLICTS.length; i += 5) {
    const batch = BASE_CONFLICTS.slice(i, i + 5);
    const results = await Promise.all(batch.map(processConflict));
    updated.push(...results);
    if (i + 5 < BASE_CONFLICTS.length) await new Promise(r => setTimeout(r, 300));
  }

  await store.setJSON("conflicts", {
    conflicts: updated,
    lastUpdated: new Date().toISOString()
  });

  console.log(`✅ Updated ${updated.length} conflicts at ${new Date().toISOString()}`);
};

export const config = {
  schedule: "@daily"
};
