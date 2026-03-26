export default async (req) => {
  try {
    const url = "https://api.gdeltproject.org/api/v2/doc/doc?query=Ukraine+war&mode=artlist&maxrecords=3&timespan=48h&format=json";
    const res = await fetch(url, { signal: AbortSignal.timeout(8000) });
    const text = await res.text();
    return new Response(JSON.stringify({
      status: res.status,
      contentType: res.headers.get("content-type"),
      bodyLength: text.length,
      body: text.substring(0, 500)
    }, null, 2), { headers: { "Content-Type": "application/json" } });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message, stack: e.stack }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
};
export const config = { path: "/api/test-gdelt" };
