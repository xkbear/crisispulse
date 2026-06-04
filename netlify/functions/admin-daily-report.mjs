import { getStore } from "@netlify/blobs";

/**
 * Daily admin report — sent every 24h to the project operator.
 *
 * Contents
 *   • Total subscribers + delta vs yesterday
 *   • New signups in the last 24h (email + country)
 *   • Subscriber country breakdown (top 10)
 *   • Visitor total + top 5 countries
 *   • Today's top news headlines (Top 5 conflicts)
 *
 * Also persists a snapshot to `admin-history/daily` so future runs can
 * compute deltas against the previous day's numbers.
 */

const RESEND_API_KEY = "re_FkyNsECz_GHxJJs1ZVZsoKUu1paaFZf1a";
const FROM_EMAIL = "alerts@crisispulse.org";
const TO_EMAIL = "pin@beebee.ai";

async function sendEmail(subject, html) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: [TO_EMAIL],
      subject,
      html,
      tags: [
        { name: "campaign", value: "admin_daily" },
        { name: "kind",     value: "internal_report" }
      ]
    })
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    console.error(`Admin report send failed: ${res.status} ${body}`);
  }
  return res.ok;
}

function fmtDate(d) {
  return d.toLocaleDateString("en-US", { weekday: "long", year: "numeric", month: "long", day: "numeric" });
}

function relativeSign(n) {
  if (n > 0) return `<span style="color:#22c55e">+${n}</span>`;
  if (n < 0) return `<span style="color:#ef4444">${n}</span>`;
  return `<span style="color:#888">0</span>`;
}

function buildReport({ subs, prevTotal, newSubs24h, visitor, topNews }) {
  const today = fmtDate(new Date());
  const total = subs.length;
  const delta = total - (prevTotal ?? total);

  // Country breakdown for subscribers
  const subCountries = {};
  for (const s of subs) {
    subCountries[s.country || "Unknown"] = (subCountries[s.country || "Unknown"] || 0) + 1;
  }
  const subTopCountries = Object.entries(subCountries)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10);

  // New signups list
  const newSubsRows = newSubs24h.length === 0
    ? `<tr><td colspan="2" style="padding:10px;color:#888;font-style:italic">No new signups in the last 24h.</td></tr>`
    : newSubs24h.map(s => `
        <tr>
          <td style="padding:6px 10px;border-bottom:1px solid #eee;color:#333">${s.email}</td>
          <td style="padding:6px 10px;border-bottom:1px solid #eee;color:#666;font-size:12px">${s.country}</td>
        </tr>`).join("");

  // Visitor top countries
  const visitorTopCountries = Object.entries(visitor?.countries || {})
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5);

  // Top news block
  const newsRows = (topNews || []).slice(0, 5).map((n, i) => `
    <tr>
      <td style="padding:6px 10px;border-bottom:1px solid #eee;font-weight:600;color:#333;width:34%">${i+1}. ${n.conflict}</td>
      <td style="padding:6px 10px;border-bottom:1px solid #eee;color:#555;font-size:12px">${n.headline}</td>
    </tr>`).join("");

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;color:#1a1a2e;max-width:640px;margin:0 auto;padding:24px;background:#fafafa">

  <div style="background:#fff;border-radius:12px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,.06)">

    <div style="margin-bottom:24px">
      <h1 style="font-size:22px;margin:0;color:#1a1a2e">📊 Crisis Pulse — Daily Report</h1>
      <p style="color:#666;margin:4px 0 0;font-size:13px">${today}</p>
    </div>

    <!-- Top stats grid -->
    <table style="width:100%;border-collapse:collapse;margin-bottom:24px">
      <tr>
        <td style="padding:14px 16px;background:#eff6ff;border-radius:10px;width:50%">
          <div style="font-size:11px;color:#1d4ed8;text-transform:uppercase;letter-spacing:1px;font-weight:600">Total Subscribers</div>
          <div style="font-size:28px;font-weight:800;color:#1a1a2e;margin-top:4px">${total}</div>
          <div style="font-size:12px;color:#666;margin-top:2px">vs yesterday: ${relativeSign(delta)}</div>
        </td>
        <td style="width:10px"></td>
        <td style="padding:14px 16px;background:#fef3c7;border-radius:10px;width:50%">
          <div style="font-size:11px;color:#b45309;text-transform:uppercase;letter-spacing:1px;font-weight:600">Total Visitors (all-time)</div>
          <div style="font-size:28px;font-weight:800;color:#1a1a2e;margin-top:4px">${(visitor?.total || 0).toLocaleString()}</div>
          <div style="font-size:12px;color:#666;margin-top:2px">${Object.keys(visitor?.countries || {}).length} countries</div>
        </td>
      </tr>
    </table>

    <!-- New signups in last 24h -->
    <h2 style="font-size:15px;font-weight:600;margin:8px 0 12px;color:#1a1a2e">🌱 New signups (last 24h) — ${newSubs24h.length}</h2>
    <table style="width:100%;border-collapse:collapse;font-size:13px;margin-bottom:24px;border:1px solid #eee;border-radius:8px;overflow:hidden">
      <thead>
        <tr style="background:#f8f9fa">
          <th style="padding:8px 10px;text-align:left;border-bottom:1px solid #ddd;font-size:11px;color:#666;text-transform:uppercase">Email</th>
          <th style="padding:8px 10px;text-align:left;border-bottom:1px solid #ddd;font-size:11px;color:#666;text-transform:uppercase">Country</th>
        </tr>
      </thead>
      <tbody>${newSubsRows}</tbody>
    </table>

    <!-- Subscriber country breakdown -->
    <h2 style="font-size:15px;font-weight:600;margin:8px 0 12px;color:#1a1a2e">🌍 Subscribers by country</h2>
    <div style="margin-bottom:24px">
      ${subTopCountries.map(([country, count]) => {
        const pct = (count / total * 100).toFixed(0);
        return `
          <div style="margin-bottom:6px">
            <div style="display:flex;justify-content:space-between;font-size:12px;color:#333">
              <span>${country}</span><span><strong>${count}</strong> (${pct}%)</span>
            </div>
            <div style="height:6px;background:#eee;border-radius:3px;overflow:hidden">
              <div style="width:${pct}%;height:100%;background:#3b82f6"></div>
            </div>
          </div>`;
      }).join("")}
    </div>

    <!-- Top visitor countries -->
    <h2 style="font-size:15px;font-weight:600;margin:8px 0 12px;color:#1a1a2e">👀 Top visitor countries</h2>
    <table style="width:100%;border-collapse:collapse;font-size:13px;margin-bottom:24px">
      ${visitorTopCountries.map(([country, count]) => `
        <tr>
          <td style="padding:6px 10px;color:#333">${country}</td>
          <td style="padding:6px 10px;text-align:right;font-weight:600;color:#1a1a2e">${count.toLocaleString()}</td>
        </tr>`).join("")}
    </table>

    <!-- Today's top news -->
    ${newsRows ? `
      <h2 style="font-size:15px;font-weight:600;margin:8px 0 12px;color:#1a1a2e">📰 Top news today</h2>
      <table style="width:100%;border-collapse:collapse;font-size:13px;margin-bottom:24px;border:1px solid #eee;border-radius:8px;overflow:hidden">
        <tbody>${newsRows}</tbody>
      </table>
    ` : ""}

    <hr style="border:none;border-top:1px solid #eee;margin:24px 0">
    <p style="font-size:11px;color:#999;text-align:center;line-height:1.5">
      Generated automatically by the Crisis Pulse admin pipeline.<br>
      <a href="https://crisispulse.org" style="color:#999">crisispulse.org</a>
    </p>
  </div>
</body>
</html>`;
}

export default async () => {
  try {
    const subStore = getStore("subscribers");
    const visitorStore = getStore("visitor-stats");
    const conflictStore = getStore("conflict-data");
    const adminStore = getStore("admin-history");

    // Load subscribers
    const subData = await subStore.get("emails", { type: "json" });
    const subs = subData?.subscribers || [];

    // Load visitor stats
    const visitor = await visitorStore.get("counts", { type: "json" });

    // Load latest conflicts (for top news block)
    const conflictData = await conflictStore.get("conflicts", { type: "json" });
    const topNews = conflictData?.topNews || [];

    // Previous day snapshot for delta computation
    const prev = await adminStore.get("daily", { type: "json" });
    const prevTotal = prev?.totalSubscribers ?? null;

    // New signups in last 24h
    const cutoff = Date.now() - 24 * 60 * 60 * 1000;
    const newSubs24h = subs.filter(s => {
      const t = new Date(s.subscribedAt).getTime();
      return !isNaN(t) && t >= cutoff;
    });

    const html = buildReport({ subs, prevTotal, newSubs24h, visitor, topNews });

    const dateStr = new Date().toISOString().slice(0, 10);
    const subject = `📊 Crisis Pulse Daily — ${subs.length} subscribers${newSubs24h.length ? ` (+${newSubs24h.length})` : ""} · ${dateStr}`;

    const ok = await sendEmail(subject, html);

    // Save today's snapshot so tomorrow's run can compute delta
    await adminStore.setJSON("daily", {
      totalSubscribers: subs.length,
      totalVisitors: visitor?.total || 0,
      countries: Object.keys(visitor?.countries || {}).length,
      timestamp: new Date().toISOString()
    });

    return Response.json({
      ok,
      total: subs.length,
      newToday: newSubs24h.length,
      delta: prevTotal != null ? subs.length - prevTotal : null
    });
  } catch (err) {
    console.error("admin-daily-report error:", err);
    return Response.json(
      { ok: false, error: err?.message || String(err), name: err?.name || null },
      { status: 500 }
    );
  }
};

export const config = {
  // Daily at midnight UTC — same window as update-conflicts
  schedule: "@daily",
  path: "/api/admin-daily-report"
};
