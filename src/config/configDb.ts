import mysql from "mysql2/promise";

// Đọc từ các file config....xml thông qua configManager
// Database config sẽ được truyền qua parameter
export async function getConnection(dbConfig?: {
  host: string;
  port: number;
  database: string;
  username: string;
  password: string;
}) {
  // Nếu không truyền config, throw error để buộc phải truyền config
  if (!dbConfig) {
    throw new Error(
      "Database config is required. Please provide dbConfig parameter."
    );
  }

  console.log(
    `Connecting to database: ${dbConfig.database} on ${dbConfig.host}:${dbConfig.port}`
  );

  return await mysql.createConnection({
    host: dbConfig.host,
    port: dbConfig.port,
    user: dbConfig.username,
    password: dbConfig.password,
    database: dbConfig.database,
  });
}
