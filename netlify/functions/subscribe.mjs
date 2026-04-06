import { getStore } from "@netlify/blobs";

const RESEND_API_KEY = "re_FkyNsECz_GHxJJs1ZVZsoKUu1paaFZf1a";
const FROM_EMAIL = "alerts@crisispulse.org";

async function sendWelcomeEmail(to) {
  const html = `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;color:#1a1a2e;max-width:600px;margin:0 auto;padding:20px">
  <div style="text-align:center;margin-bottom:24px">
    <h1 style="font-size:22px;margin:0;color:#1a1a2e">🌍 Welcome to Crisis Pulse</h1>
    <p style="color:#666;margin:6px 0 0;font-size:14px">You're now subscribed to conflict alerts</p>
  </div>

  <p style="font-size:14px;line-height:1.8;color:#333">
    Thanks for subscribing! Here's what you'll get:
  </p>
  <ul style="font-size:14px;line-height:2;color:#333">
    <li><strong>🔴 Escalation alerts</strong> — when any tracked conflict intensity spikes significantly</li>
    <li><strong>📊 Daily brief</strong> — top 5 conflicts by intensity, delivered once per day</li>
  </ul>

  <div style="text-align:center;margin:24px 0">
    <a href="https://crisispulse.org" style="display:inline-block;padding:12px 28px;background:#e67e22;color:#fff;text-decoration:none;border-radius:8px;font-weight:600;font-size:14px">
      View Live Crisis Map →
    </a>
  </div>

  <hr style="border:none;border-top:1px solid #eee;margin:24px 0">
  <p style="font-size:11px;color:#999;text-align:center;line-height:1.5">
    Crisis Pulse · Free · Open source · No data collected<br>
    <a href="https://crisispulse.org" style="color:#999">crisispulse.org</a>
  </p>
</body>
</html>`;

  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: [to],
        subject: "🌍 Welcome to Crisis Pulse — You're subscribed!",
        html
      })
    });
    const data = await res.json();
    console.log(`Welcome email to ${to}:`, res.ok ? "sent" : data);
    return res.ok;
  } catch (err) {
    console.error(`Welcome email failed for ${to}:`, err);
    return false;
  }
}

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

    // Send welcome confirmation email
    await sendWelcomeEmail(email);

    return Response.json({ ok: true, message: "subscribed", count: list.subscribers.length }, { headers });
  } catch (err) {
    console.error("Subscribe error:", err);
    return Response.json({ ok: false, error: "Server error" }, { status: 500, headers });
  }
};

export const config = { path: "/api/subscribe" };
