import { getStore } from "@netlify/blobs";

export default async (req, context) => {
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Cache-Control": "no-cache"
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers });
  }

  try {
    const body = await req.json().catch(() => ({}));
    const email = (body.email || "").trim().toLowerCase();

    // Basic email validation
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return Response.json({ ok: false, error: "Invalid email" }, { status: 400, headers });
    }

    const store = getStore("subscribers");
    let list = await store.get("emails", { type: "json" });
    if (!list) list = { subscribers: [] };

    // Check duplicate
    if (list.subscribers.some(s => s.email === email)) {
      return Response.json({ ok: true, message: "already_subscribed" }, { headers });
    }

    // Add subscriber
    list.subscribers.push({
      email,
      country: body.country || "Unknown",
      subscribedAt: new Date().toISOString()
    });

    await store.setJSON("emails", list);
    return Response.json({ ok: true, message: "subscribed", count: list.subscribers.length }, { headers });
  } catch (err) {
    console.error("Subscribe error:", err);
    return Response.json({ ok: false, error: "Server error" }, { status: 500, headers });
  }
};

export const config = { path: "/api/subscribe" };
