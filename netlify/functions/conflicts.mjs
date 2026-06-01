import { getStore } from "@netlify/blobs";

export default async (req) => {
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Cache-Control": "public, max-age=3600, s-maxage=3600",
    "Content-Type": "application/json"
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers });
  }

  try {
    const store = getStore("conflict-data");
    const data = await store.get("conflicts", { type: "json" });
    if (data) {
      return Response.json(data, { headers });
    }
    return Response.json({ conflicts: null, lastUpdated: null }, { headers });
  } catch (err) {
    // Surface the actual error message + name so we can debug without
    // having to tail Netlify function logs.
    console.error("Conflicts API error:", err);
    return Response.json(
      {
        error: "Internal error",
        message: err?.message || String(err),
        name: err?.name || null,
        conflicts: null,
        lastUpdated: null
      },
      { status: 500, headers }
    );
  }
};

export const config = { path: "/api/conflicts" };
