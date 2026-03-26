import { getStore } from "@netlify/blobs";

// Send conflict escalation alerts to subscribers via Resend
const RESEND_API_KEY = "re_FkyNsECz_GHxJJs1ZVZsoKUu1paaFZf1a";
const FROM_EMAIL = "alerts@crisispulse.org";

async function sendEmail(to, subject, html) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ from: FROM_EMAIL, to: [to], subject, html })
  });
  return res.ok;
}

function buildAlertEmail(escalations) {
  const rows = escalations.map(e => `
    <tr>
      <td style="padding:10px 12px;border-bottom:1px solid #eee;font-weight:600">${e.name}</td>
      <td style="padding:10px 12px;border-bottom:1px solid #eee;color:#dc2626">${e.prevIntensity} → ${e.newIntensity}</td>
      <td style="padding:10px 12px;border-bottom:1px solid #eee;font-size:13px;color:#555">${e.desc}</td>
    </tr>
  `).join("");

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;color:#1a1a2e;max-width:600px;margin:0 auto;padding:20px">
  <div style="text-align:center;margin-bottom:24px">
    <h1 style="font-size:22px;margin:0;color:#1a1a2e">⚠️ Crisis Pulse Alert</h1>
    <p style="color:#666;margin:6px 0 0;font-size:14px">Conflict Escalation Detected</p>
  </div>

  <p style="font-size:14px;line-height:1.6;color:#333">
    The following conflicts have seen significant escalation in the past 24 hours:
  </p>

  <table style="width:100%;border-collapse:collapse;margin:16px 0;font-size:14px">
    <thead>
      <tr style="background:#f8f9fa">
        <th style="padding:10px 12px;text-align:left;border-bottom:2px solid #ddd">Conflict</th>
        <th style="padding:10px 12px;text-align:left;border-bottom:2px solid #ddd">Intensity</th>
        <th style="padding:10px 12px;text-align:left;border-bottom:2px solid #ddd">Latest</th>
      </tr>
    </thead>
    <tbody>${rows}</tbody>
  </table>

  <div style="text-align:center;margin:24px 0">
    <a href="https://crisispulse.org" style="display:inline-block;padding:12px 28px;background:#e67e22;color:#fff;text-decoration:none;border-radius:8px;font-weight:600;font-size:14px">
      View Live Map →
    </a>
  </div>

  <hr style="border:none;border-top:1px solid #eee;margin:24px 0">
  <p style="font-size:11px;color:#999;text-align:center;line-height:1.5">
    You received this because you subscribed to Crisis Pulse alerts.<br>
    <a href="https://crisispulse.org" style="color:#999">crisispulse.org</a> · Open source · No data collected
  </p>
</body>
</html>`;
}

export default async (req, context) => {
  // Called internally by update-conflicts when escalations detected
  const headers = { "Content-Type": "application/json" };

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { escalations } = await req.json();
    if (!escalations || escalations.length === 0) {
      return Response.json({ ok: true, sent: 0 }, { headers });
    }

    // Get subscriber list
    const subStore = getStore("subscribers");
    const data = await subStore.get("list", { type: "json" });
    const subscribers = data?.subscribers || [];

    if (subscribers.length === 0) {
      return Response.json({ ok: true, sent: 0, reason: "no subscribers" }, { headers });
    }

    const subject = `⚠️ ${escalations.length} conflict${escalations.length > 1 ? 's' : ''} escalated — Crisis Pulse`;
    const html = buildAlertEmail(escalations);

    let sent = 0;
    let failed = 0;

    // Send to each subscriber (Resend free tier: 100/day)
    for (const sub of subscribers.slice(0, 90)) { // safety cap
      try {
        const ok = await sendEmail(sub.email, subject, html);
        if (ok) sent++; else failed++;
      } catch (_) {
        failed++;
      }
    }

    console.log(`Notified ${sent}/${subscribers.length} subscribers (${failed} failed)`);
    return Response.json({ ok: true, sent, failed, total: subscribers.length }, { headers });

  } catch (err) {
    console.error("Notify error:", err);
    return Response.json({ ok: false, error: err.message }, { status: 500, headers });
  }
};

export const config = { path: "/api/notify" };
