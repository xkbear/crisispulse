import { getStore } from "@netlify/blobs";

/**
 * Email unsubscribe endpoint.
 * Supports two flows:
 *  1) GET  /unsubscribe?email=xxx     (browser link from email footer)
 *  2) POST /unsubscribe               (Gmail/Apple Mail one-click via List-Unsubscribe-Post header)
 */
export default async (req, context) => {
  const url = new URL(req.url);
  let email = url.searchParams.get("email");

  // RFC 8058: Gmail/Apple one-click sends POST with form data
  if (req.method === "POST" && !email) {
    try {
      const body = await req.text();
      const params = new URLSearchParams(body);
      email = params.get("email") || email;
      // The header `List-Unsubscribe-Post: List-Unsubscribe=One-Click`
      // tells Gmail it can POST without further confirmation.
    } catch (_) {}
  }

  if (!email) {
    return htmlResponse(400, "Missing <code>email</code> parameter.");
  }

  const cleaned = email.trim().toLowerCase();

  try {
    const store = getStore("subscribers");
    let data = await store.get("emails", { type: "json" });
    if (!data) data = { subscribers: [] };

    const before = data.subscribers.length;
    data.subscribers = data.subscribers.filter(s => s.email.toLowerCase() !== cleaned);
    const removed = before - data.subscribers.length;

    if (removed > 0) {
      await store.setJSON("emails", data);
    }

    // Gmail expects 200 OK on POST (no body required).
    if (req.method === "POST") {
      return new Response(null, { status: 200 });
    }

    if (removed > 0) {
      return htmlResponse(200, `
        <h1>You're unsubscribed</h1>
        <p>The address <strong>${escapeHtml(cleaned)}</strong> will no longer receive Crisis Pulse emails.</p>
        <p>Sorry to see you go. If this was a mistake, you can re-subscribe any time at
        <a href="https://crisispulse.org">crisispulse.org</a>.</p>
      `);
    } else {
      return htmlResponse(200, `
        <h1>Already unsubscribed</h1>
        <p>The address <strong>${escapeHtml(cleaned)}</strong> wasn't on our list.</p>
        <p><a href="https://crisispulse.org">Back to Crisis Pulse</a></p>
      `);
    }
  } catch (err) {
    console.error("Unsubscribe error:", err);
    return htmlResponse(500, "Something went wrong. Please email <a href=\"mailto:hello@crisispulse.org\">hello@crisispulse.org</a> to be removed.");
  }
};

function htmlResponse(status, inner) {
  const body = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Crisis Pulse — Unsubscribe</title>
<meta name="robots" content="noindex">
<style>
  body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;background:#0a0a0f;color:#e6e6e6;line-height:1.7;margin:0}
  .wrap{max-width:520px;margin:0 auto;padding:80px 24px}
  h1{font-size:26px;margin:0 0 16px;color:#fff}
  p{color:#bbb;margin:0 0 14px}
  strong{color:#fff}
  a{color:#60a5fa}
</style></head>
<body><div class="wrap">${inner}</div></body></html>`;
  return new Response(body, {
    status,
    headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" }
  });
}

function escapeHtml(s) {
  return String(s).replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
}

export const config = { path: "/unsubscribe" };
