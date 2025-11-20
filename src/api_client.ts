// api_client.ts
import axios from "axios";

const cache = new Map<string, any>();

export async function fetchWithRetry(
  url: string,
  retries = 3,
  backoff = 500 // 0.5s
): Promise<any> {

  // ---- Caching Layer ----
  if (cache.has(url)) {
    console.log("[CACHE HIT]:", url);
    return cache.get(url);
  }

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const res = await axios.get(url);
      cache.set(url, res.data); // save cache
      return res.data;
    } catch (err: any) {
      const status = err?.response?.status;

      // Rate limit
      if (status === 429) {
        console.warn("Rate limit hit → waiting before retry...");
      }

      if (attempt === retries) {
        throw err; // give up
      }

      const waitTime = backoff * attempt;
      console.warn(`Retry ${attempt}/${retries} after ${waitTime}ms`);
      await new Promise((resolve) => setTimeout(resolve, waitTime));
    }
  }
}
