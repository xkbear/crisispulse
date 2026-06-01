import { getStore } from "@netlify/blobs";

export default async (req, context) => {
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Cache-Control": "no-cache"
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers });
  }

  // Hard upper bound for Blob operations — never let one hang request
  // long enough to trigger Netlify's 10s function timeout (which returns
  // 502 with "unexpected end of JSON input").
  const blobTimeout = (promise, ms = 4000) => Promise.race([
    promise,
    new Promise((_, reject) => setTimeout(() => reject(new Error("blob timeout")), ms))
  ]);

  let store;
  try {
    store = getStore("visitor-stats");
  } catch (err) {
    console.error("visitor getStore failed:", err);
    return Response.json(
      { error: "store unavailable", message: String(err?.message || err), total: 0, countries: {} },
      { status: 503, headers }
    );
  }

  try {
    if (req.method === "GET") {
      const data = await blobTimeout(store.get("counts", { type: "json" }));
      return Response.json(data || { total: 0, countries: {} }, { headers });
    }

    if (req.method === "POST") {
      const body = await req.json().catch(() => ({}));
      let country = (body.country || "").trim();

      // Fallback: use Netlify's IP-based geo when GPS country unavailable
      if (!country || country === "Unknown") {
        const geo = context.geo || {};
        country = geo.country?.name || geo.country || "";
        // Netlify geo may return country code, map common ones
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
          RO:"Romania",HK:"Hong Kong",PY:"Paraguay",UY:"Uruguay",CR:"Costa Rica"
        };
        if (country.length === 2) country = CODE_TO_NAME[country] || country;
        if (!country) country = "Unknown";
      }

      let data = await blobTimeout(store.get("counts", { type: "json" }));
      if (!data) data = { total: 0, countries: {} };

      data.total += 1;
      data.countries[country] = (data.countries[country] || 0) + 1;

      await blobTimeout(store.setJSON("counts", data));
      // Return detected country so frontend knows what was recorded
      return Response.json({ ...data, detectedCountry: country }, { headers });
    }

    return new Response("Method not allowed", { status: 405, headers });
  } catch (err) {
    console.error("Visitor function error:", err);
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
