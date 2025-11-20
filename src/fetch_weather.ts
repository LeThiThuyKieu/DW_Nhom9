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

export function saveToCSV(data: WeatherData[]): string {
  const stagingConfig = configManager.getStagingConfig();
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");
  const hour = String(now.getHours()).padStart(2, "0");
  const minute = String(now.getMinutes()).padStart(2, "0");

  const filename = `data_${year}${month}${day}_${hour}${minute}.csv`;
  const filepath = path.join(stagingConfig.directory, filename);

  // Tạo header CSV
  const headers = [
    "city",
    "latitude",
    "longitude",
    "elevation",
    "utc_offset_seconds",
    "timezone",
    "timezone_abbreviation",
    "time",
    "temperature_2m",
    "humidity_2m",
  ];

  // Tạo content CSV
  const csvContent = [
    headers.join(","),
    ...data.map((item) =>
      [
        `"${item.city}"`,
        item.latitude,
        item.longitude,
        item.elevation,
        item.utc_offset_seconds,
        `"${item.timezone}"`,
        `"${item.timezone_abbreviation}"`,
        `"${item.time}"`,
        item.temperature_2m,
        item.humidity_2m,
      ].join(",")
    ),
  ].join("\n");

  // Đảm bảo folder tồn tại
  if (!fs.existsSync(stagingConfig.directory)) {
    fs.mkdirSync(stagingConfig.directory, { recursive: true });
  }

  // Ghi file
  fs.writeFileSync(filepath, csvContent, "utf8");

  console.log(`Data saved to: ${filepath}`);
  return filepath;
}

export async function fetchAndSaveWeatherData(
  configLogId?: number
): Promise<string> {
  let processLogId: number | undefined;

  try {
    // Load config
    await configManager.loadConfig();

    // Log process start
    processLogId = await controlDBManager.logProcess(
      "Weather Data Fetch",
      "FETCH",
      configLogId
    );

    console.log("Fetching weather data from API...");
    const weatherData = await fetchWeatherData();

    if (weatherData.length === 0) {
      throw new Error("No weather data fetched");
    }

    console.log(`Fetched ${weatherData.length} weather records`);
    const filepath = saveToCSV(weatherData);

    // Update process log
    await controlDBManager.updateProcessLogStatus(
      processLogId,
      "SUCCESS",
      weatherData.length
    );

    return filepath;
  } catch (error) {
    console.error("Error in fetchAndSaveWeatherData:", error);

    if (processLogId) {
      await controlDBManager.updateProcessLogStatus(
        processLogId,
        "FAILED",
        0,
        error instanceof Error ? error.message : String(error)
      );
    }

    throw error;
  }
}

if (require.main === module) {
  fetchAndSaveWeatherData()
    .then((filepath) => {
      console.log(`Successfully saved weather data to: ${filepath}`);
    })
    .catch((error) => {
      console.error("Error:", error);
      process.exit(1);
    });
}
