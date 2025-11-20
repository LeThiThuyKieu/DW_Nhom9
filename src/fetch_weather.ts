import { fetchWithRetry } from "./api_client";
import fs from "fs";
import path from "path";
import { configManager, controlDBManager } from "./config_manager";

interface WeatherData {
  city: string;
  latitude: number;
  longitude: number;
  elevation: number;
  utc_offset_seconds: number;
  timezone: string;
  timezone_abbreviation: string;
  time: string;
  temperature_2m: number;
  humidity_2m: number;
}

export async function fetchWeatherData(): Promise<WeatherData[]> {
  const weatherAPIConfig = configManager.getWeatherAPIConfig();
  const weatherData: WeatherData[] = [];

  // Debug: Log config để xem cấu trúc
  // console.log("Weather API Config:", JSON.stringify(weatherAPIConfig, null, 2));

  // Xử lý cities - có thể là array hoặc object
  let cities: any = weatherAPIConfig.cities;

  // Nếu cities có thuộc tính 'city', lấy array từ đó
  if (cities && cities.city) {
    cities = cities.city;
  }

  if (!Array.isArray(cities)) {
    // Nếu cities là object, chuyển thành array
    if (cities && typeof cities === "object") {
      // Nếu có thuộc tính $ hoặc các thuộc tính khác, có thể là xml2js object
      if (cities.$) {
        // Single city object
        cities = [cities];
      } else {
        // Multiple cities as object with numeric keys
        cities = Object.values(cities);
      }
    } else {
      console.error("Cities config is not valid:", cities);
      return weatherData;
    }
  }

  // console.log("Cities array:", cities);

  for (const city of cities) {
    try {
      
      const url = `${weatherAPIConfig.url}?latitude=${city.latitude}&longitude=${city.longitude}&hourly=${weatherAPIConfig.parameters.hourly}&timezone=Asia%2FHo_Chi_Minh`;

     
      const data = await fetchWithRetry(url);

      // Lấy dữ liệu đúng giờ 07:00 theo VN
      if (data.hourly && data.hourly.time && data.hourly.time.length > 0) {
        // Lấy ngày hôm nay theo giờ Việt Nam
        const now = new Date();
        const dateString = now.toISOString().slice(0, 10); // YYYY-MM-DD

        // Cố định giờ 07:00
        const targetHourString = `${dateString}T07`;

        // Tìm index của giờ 07:00
        const index = data.hourly.time.findIndex((t: string) =>
          t.startsWith(targetHourString)
        );

        if (index !== -1) {
          const weatherItem: WeatherData = {
            city: city.name,
            latitude: data.latitude,
            longitude: data.longitude,
            elevation: data.elevation,
            utc_offset_seconds: data.utc_offset_seconds,
            timezone: data.timezone,
            timezone_abbreviation: data.timezone_abbreviation,
            time: data.hourly.time[index],
            temperature_2m: data.hourly.temperature_2m[index],
            humidity_2m: data.hourly.relative_humidity_2m[index],
          };

          weatherData.push(weatherItem);
        } else {
          console.warn(`Không tìm thấy dữ liệu 07:00 cho ${city.name}`);
        }
      }
    } catch (error) {
      console.error(`Error fetching data for ${city.name}:`, error);
    }
  }

  return weatherData;
}
