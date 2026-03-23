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

  const store = getStore("visitor-stats");

  try {
    if (req.method === "GET") {
      const data = await store.get("counts", { type: "json" });
      return Response.json(data || { total: 0, countries: {} }, { headers });
    }

    if (req.method === "POST") {
      const body = await req.json().catch(() => ({}));
      const country = (body.country || "").trim() || "Unknown";

      let data = await store.get("counts", { type: "json" });
      if (!data) data = { total: 0, countries: {} };

      data.total += 1;
      data.countries[country] = (data.countries[country] || 0) + 1;

      await store.setJSON("counts", data);
      return Response.json(data, { headers });
    }

    return new Response("Method not allowed", { status: 405, headers });
  } catch (err) {
    console.error("Visitor function error:", err);
    return Response.json(
      { error: "Internal error", total: 0, countries: {} },
      { status: 500, headers }
    );
  }
};

export const config = { path: "/api/visitor" };
