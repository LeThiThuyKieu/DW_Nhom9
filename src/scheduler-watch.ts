import cron, { ScheduledTask } from "node-cron";
import fs from "fs";
import { XMLParser } from "fast-xml-parser";
import { runScheduledETL } from "./etl_process";

let currentTask: ScheduledTask | null = null;
const CONFIG_PATH = "./config-dev.xml";

function loadScheduleFromConfig(): string {
  const xmlData = fs.readFileSync(CONFIG_PATH, "utf-8");
  const parser = new XMLParser({ ignoreAttributes: false });
  const jsonObj = parser.parse(xmlData);
  const schedule =
    jsonObj["datawarehouse-config"]?.["etl-processes"]?.fetch?.schedule || "0 7 * * *";
  return schedule;
}


function startCron(schedule: string) {
  if (currentTask) {
    currentTask.stop(); // dừng cron job cũ
    console.log("Cron job cũ đã dừng.");
  }

  console.log("Khởi động cron job mới với schedule:", schedule);
  currentTask = cron.schedule(schedule, async () => {
    console.log(`[${new Date().toLocaleString()}] Bắt đầu chạy ETL...`);
    try {
      await runScheduledETL();
      console.log(`[${new Date().toLocaleString()}] ETL hoàn thành!`);
    } catch (err) {
      console.error(`[${new Date().toLocaleString()}] ETL error:`, err);
    }
  });
  currentTask.start();
}

// Load schedule lần đầu
let schedule = loadScheduleFromConfig();
startCron(schedule);

// Watch file config
fs.watch(CONFIG_PATH, (eventType) => {
  if (eventType === "change") {
    console.log("\nConfig file thay đổi, reload schedule...");
    try {
      const newSchedule = loadScheduleFromConfig();
      if (newSchedule !== schedule) {
        schedule = newSchedule;
        startCron(schedule);
      } else {
        console.log("Schedule không thay đổi, giữ cron hiện tại.");
      }
    } catch (err) {
      console.error("Không thể reload config:", err);
    }
  }
});
