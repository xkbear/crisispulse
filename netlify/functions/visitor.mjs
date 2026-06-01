import { getStore } from "@netlify/blobs";

const CODE_TO_NAME = {
  US:"United States",GB:"United Kingdom",CN:"China",JP:"Japan",DE:"Germany",
  FR:"France",IN:"India",BR:"Brazil",CA:"Canada",AU:"Australia",KR:"South Korea",
  RU:"Russia",MX:"Mexico",IT:"Italy",ES:"Spain",TR:"Turkey",ID:"Indonesia",
  NL:"Netherlands",TW:"Taiwan",TH:"Thailand",VN:"Vietnam",PH:"Philippines",
  PL:"Poland",SE:"Sweden",SG:"Singapore",MY:"Malaysia",IL:"Israel",UA:"Ukraine",
  NZ:"New Zealand",AR:"Argentina",CO:"Colombia",EG:"Egypt",NG:"Nigeria",
  ZA:"South Africa",SA:"Saudi Arabia",IR:"Iran",PK:"Pakistan",BD:"Bangladesh",
  CL:"Chile",PE:"Peru",PT:"Portugal",IE:"Ireland",NO:"Norway",DK:"Denmark",
  FI:"Finland",CH:"Switzerland",AT:"Austria",BE:"Belgium",CZ:"Czech Republic",
  RO:"Romania",HK:"Hong Kong",PY:"Paraguay",UY:"Uruguay",CR:"Costa Rica",
  IQ:"Iraq",ET:"Ethiopia",KE:"Kenya",GH:"Ghana",MA:"Morocco",DZ:"Algeria"
};

export default async (req, context) => {
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Cache-Control": "no-cache",
    "Content-Type": "application/json"
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers });
  }

  try {
    const store = getStore("visitor-stats");

    if (req.method === "GET") {
      const data = await store.get("counts", { type: "json" });
      return Response.json(data || { total: 0, countries: {} }, { headers });
    }

    if (req.method === "POST") {
      let country = "";
      try {
        const body = await req.json();
        country = (body?.country || "").trim();
      } catch (_) { /* empty body is fine */ }

      // Fallback to Netlify's IP-based geo when client didn't pass country
      if (!country || country === "Unknown") {
        const geo = context?.geo || {};
        country = geo.country?.name || geo.country || "";
        if (country && country.length === 2) {
          country = CODE_TO_NAME[country] || country;
        }
        if (!country) country = "Unknown";
      }

      let data = await store.get("counts", { type: "json" });
      if (!data) data = { total: 0, countries: {} };

      data.total = (data.total || 0) + 1;
      data.countries[country] = (data.countries[country] || 0) + 1;

      await store.setJSON("counts", data);
      return Response.json({ ...data, detectedCountry: country }, { headers });
    }

    return Response.json({ error: "Method not allowed" }, { status: 405, headers });
  } catch (err) {
    console.error("Visitor API error:", err);
    return Response.json(
      {
        error: "Internal error",
        message: err?.message || String(err),
        name: err?.name || null,
        total: 0,
        countries: {}
      },
      { status: 500, headers }
    );
  }
};

export const config = { path: "/api/visitor" };
