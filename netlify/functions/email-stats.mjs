/**
 * GET /api/email-stats?key=xxx
 *
 * Pulls the recent emails sent through Resend and aggregates open/click stats
 * by campaign tag. Protected by a shared key so only the operator (you) can
 * see who-opened-what.
 *
 * Setup:
 *   1. Generate a strong key, e.g.  openssl rand -hex 24
 *   2. Add it as a Netlify environment variable: STATS_API_KEY
 *      (Netlify dashboard → Site → Configuration → Environment variables)
 *   3. Call:  curl "https://crisispulse.org/api/email-stats?key=YOUR_KEY"
 *
 * Note: Resend tracks opens via a 1×1 transparent pixel and clicks via wrapped
 * URLs (we don't need to rewrite ourselves — Resend does it). The pixel is
 * blocked by Apple Mail Privacy Protection on iCloud.com / Apple Mail since
 * iOS 15, which inflates "open rates" for Apple users (Apple pre-fetches
 * everything). Treat opens as a directional signal, not absolute truth.
 */

const RESEND_API_KEY = "re_FkyNsECz_GHxJJs1ZVZsoKUu1paaFZf1a";

export default async (req, context) => {
  const url = new URL(req.url);
  const providedKey = url.searchParams.get("key");
  const requiredKey = process.env.STATS_API_KEY;

  if (!requiredKey) {
    return Response.json(
      { ok: false, error: "STATS_API_KEY not configured. See email-stats.mjs comments." },
      { status: 503 }
    );
  }

  if (providedKey !== requiredKey) {
    return new Response("Forbidden", { status: 403 });
  }

  try {
    // Resend list-emails endpoint. Only returns the latest 100 by default.
    // We page through up to 5 batches (= 500 emails ≈ ~60 days of daily briefs).
    let allEmails = [];
    let cursor = null;
    for (let page = 0; page < 5; page++) {
      const url = new URL("https://api.resend.com/emails");
      url.searchParams.set("limit", "100");
      if (cursor) url.searchParams.set("after", cursor);

      const r = await fetch(url, {
        headers: { Authorization: `Bearer ${RESEND_API_KEY}` }
      });
      if (!r.ok) {
        return Response.json({ ok: false, error: `Resend API ${r.status}` }, { status: 502 });
      }
      const data = await r.json();
      const batch = data.data || [];
      allEmails = allEmails.concat(batch);
      if (batch.length < 100) break;
      cursor = batch[batch.length - 1].id;
    }

    // Aggregate by campaign + day for a useful at-a-glance view.
    const byCampaign = {};
    const byDay = {};
    let totalSent = 0, totalOpened = 0, totalClicked = 0, totalBounced = 0, totalComplained = 0;

    for (const e of allEmails) {
      const tags = e.tags || [];
      const campaign = tags.find(t => t.name === "campaign")?.value || "uncategorized";
      const day = (e.created_at || e.createdAt || "").slice(0, 10);
      const opened = !!e.last_event && ["opened", "clicked", "delivered"].includes(e.last_event)
                     ? (e.last_event === "opened" || e.last_event === "clicked")
                     : false;
      const clicked = e.last_event === "clicked";
      const bounced = e.last_event === "bounced";
      const complained = e.last_event === "complained";

      const c = (byCampaign[campaign] ||= { sent: 0, opened: 0, clicked: 0, bounced: 0, complained: 0 });
      c.sent++;
      if (opened) c.opened++;
      if (clicked) c.clicked++;
      if (bounced) c.bounced++;
      if (complained) c.complained++;

      if (day) {
        const d = (byDay[day] ||= { sent: 0, opened: 0, clicked: 0 });
        d.sent++;
        if (opened) d.opened++;
        if (clicked) d.clicked++;
      }

      totalSent++;
      if (opened) totalOpened++;
      if (clicked) totalClicked++;
      if (bounced) totalBounced++;
      if (complained) totalComplained++;
    }

    // Compute rates as percentages
    const pct = (n, d) => d > 0 ? +(n / d * 100).toFixed(1) : 0;

    const summary = {
      total: { sent: totalSent, opened: totalOpened, clicked: totalClicked,
               bounced: totalBounced, complained: totalComplained },
      rates: {
        openRate:    pct(totalOpened, totalSent),
        clickRate:   pct(totalClicked, totalSent),
        ctor:        pct(totalClicked, totalOpened),  // click-to-open ratio
        bounceRate:  pct(totalBounced, totalSent),
        complaintRate: pct(totalComplained, totalSent)
      },
      byCampaign: Object.fromEntries(
        Object.entries(byCampaign).map(([k, v]) => [k, {
          ...v,
          openRate: pct(v.opened, v.sent),
          clickRate: pct(v.clicked, v.sent)
        }])
      ),
      byDay: Object.fromEntries(
        Object.entries(byDay).sort(([a], [b]) => b.localeCompare(a)).slice(0, 30)
      ),
      generatedAt: new Date().toISOString(),
      sampleSize: allEmails.length
    };

    return Response.json({ ok: true, ...summary }, {
      headers: { "Content-Type": "application/json", "Cache-Control": "no-store" }
    });
  } catch (err) {
    console.error("email-stats error:", err);
    return Response.json({ ok: false, error: err.message }, { status: 500 });
  }
};

export const config = { path: "/api/email-stats" };
