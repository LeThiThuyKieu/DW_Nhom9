# Hướng dẫn Setup Windows Task Scheduler - Chạy ETL tự động mỗi ngày

## 📋 Tổng quan

Hướng dẫn này sẽ giúp bạn setup Windows Task Scheduler để tự động chạy ETL process mỗi ngày lúc **7h sáng**.

## ⚠️ Lưu ý quan trọng

- **Task Scheduler chỉ chạy khi máy tính đang bật**
- Nếu máy tắt trước 7h → ETL không chạy (vì máy đã tắt)
- Nếu máy bật sau 7h → ETL sẽ chạy vào 7h sáng ngày hôm sau
- Nếu máy bật và chạy liên tục → ETL sẽ chạy đúng 7h sáng mỗi ngày

---

## 🚀 Các bước setup

### Bước 1: Kiểm tra file script

Đảm bảo file `run-etl-daily.bat` có trong thư mục project:

- Đường dẫn: `D:\code_nam4\DataWarehouse\weather-etl\run-etl-daily.bat`

Nếu chưa có, file này sẽ tự động chạy:

```bash
npm run run:etl
```

---

### Bước 2: Mở Windows Task Scheduler

**Cách 1: Dùng Run dialog**

1. Nhấn `Windows + R`
2. Gõ: `taskschd.msc`
3. Nhấn Enter hoặc click OK

**Cách 2: Dùng Start Menu**

1. Click Start Menu
2. Tìm "Task Scheduler"
3. Click để mở

---

### Bước 3: Tạo Task mới

1. Trong Task Scheduler, ở bên phải, tìm và click **"Create Basic Task..."**
2. Nhập thông tin:
   - **Name**: `Weather ETL Daily` (hoặc tên bạn muốn)
   - **Description**: `Tự động chạy ETL process mỗi ngày lúc 7h sáng để load dữ liệu thời tiết`
3. Click **Next**

---

### Bước 4: Thiết lập Trigger (Khi nào chạy)

1. Chọn **"Daily"** (Mỗi ngày)
2. Click **Next**
3. Cấu hình thời gian:
   - **Start**: Chọn ngày bắt đầu (mặc định là hôm nay)
   - **Time**: Chọn `07:00:00` (7h sáng)
   - **Recur every**: `1 days` (mỗi ngày)
4. Click **Next**

---

### Bước 5: Thiết lập Action (Chạy gì)

1. Chọn **"Start a program"**
2. Click **Next**

---

### Bước 6: Cấu hình Program

1. **Program/script**:

   - Click **"Browse..."**
   - Tìm và chọn file `run-etl-daily.bat` trong thư mục project
   - Hoặc nhập trực tiếp đường dẫn đầy đủ:
     ```
     `D:\code_nam4\DataWarehouse\weather-etl\run-etl-daily.bat`
     ```

2. **Add arguments (optional)**: Để trống

3. **Start in (optional)**: Nhập đường dẫn thư mục project

   ```
   D:\code_nam4\DataWarehouse\weather-etl
   ```

4. Click **Next**

---

### Bước 7: Hoàn tất

1. ✅ **Đánh dấu** "Open the Properties dialog for this task when I click Finish"
2. Click **Finish**

---

### Bước 8: Cấu hình nâng cao (QUAN TRỌNG)

Trong cửa sổ **Properties** vừa mở, cấu hình như sau:

#### Tab **General**:

- ✅ Đánh dấu **"Run whether user is logged on or not"**
  - _Để task chạy ngay cả khi không đăng nhập_
- ✅ Đánh dấu **"Run with highest privileges"**
  - _Để task có quyền cao nhất để chạy_
- **Configure for**: Chọn **"Windows 10"** hoặc **"Windows 11"** (tùy hệ điều hành của bạn)

#### Tab **Triggers**:

- Kiểm tra lại trigger đã đúng chưa:
  - **Begin the task**: `On a schedule`
  - **Settings**: `Daily`
  - **Start**: `07:00:00`
  - **Recur every**: `1 days`

#### Tab **Conditions**:

- ❌ **Bỏ đánh dấu** "Start the task only if the computer is on AC power" (nếu có)
  - _Để task chạy cả khi dùng pin_
- Các mục khác giữ nguyên

#### Tab **Settings**:

- ✅ Đánh dấu **"Allow task to be run on demand"**
  - _Để có thể chạy thủ công nếu cần_
- ✅ Đánh dấu **"Run task as soon as possible after a scheduled start is missed"**
  - _Nếu máy tắt lúc 7h, khi bật lại sẽ chạy ngay_
- ✅ Đánh dấu **"If the task fails, restart every:"**
  - Chọn: `1 minute`
  - **Attempt to restart up to**: `3 times`
- ✅ Đánh dấu **"If the running task does not end when requested, force it to stop"**
  - _Để tránh task bị treo_

#### Tab **Actions**:

- Kiểm tra lại action đã đúng chưa:
  - **Action**: `Start a program`
  - **Program/script**: Đường dẫn đến `run-etl-daily.bat`
  - **Start in**: Đường dẫn thư mục project

#### Tab **History**:

- Giữ nguyên mặc định

Sau khi cấu hình xong, click **OK**

- Nếu có yêu cầu nhập password admin, nhập password của tài khoản Windows

---

### Bước 9: Test thử

1. Trong Task Scheduler, tìm task **"Weather ETL Daily"** vừa tạo
2. Click chuột phải vào task → chọn **"Run"**
3. Đợi vài giây để task chạy
4. Kiểm tra kết quả:
   - Xem tab **"History"** của task để xem log
   - Hoặc kiểm tra trong database xem có dữ liệu mới không

---

## ✅ Kiểm tra sau khi setup

### Cách 1: Kiểm tra trong Task Scheduler

1. Mở Task Scheduler
2. Tìm task **"Weather ETL Daily"**
3. Xem cột **"Last Run Result"**:
   - `0x0` = Thành công ✅
   - `0x1` hoặc khác = Có lỗi ❌

### Cách 2: Kiểm tra logs

Logs của ETL sẽ được hiển thị trong:

- Console output khi chạy
- Database logs (nếu có cấu hình logging)

### Cách 3: Kiểm tra database

Chạy query để kiểm tra dữ liệu mới:

```sql
-- Kiểm tra dữ liệu mới nhất
SELECT * FROM weatherdb_dev.transform_weather
ORDER BY time DESC LIMIT 10;

-- Kiểm tra trong datawarehouse
SELECT * FROM datawarehouse.fact_weather
ORDER BY loaded_at DESC LIMIT 10;
```

---

## 🔧 Quản lý Task

### Chạy thủ công (Run on demand)

1. Mở Task Scheduler
2. Tìm task **"Weather ETL Daily"**
3. Click chuột phải → **"Run"**

### Dừng task đang chạy

1. Mở Task Scheduler
2. Tìm task **"Weather ETL Daily"**
3. Click chuột phải → **"End"**

### Tạm dừng task (Disable)

1. Mở Task Scheduler
2. Tìm task **"Weather ETL Daily"**
3. Click chuột phải → **"Disable"**

Để bật lại: Click chuột phải → **"Enable"**

### Xóa task

1. Mở Task Scheduler
2. Tìm task **"Weather ETL Daily"**
3. Click chuột phải → **"Delete"**
4. Xác nhận xóa

### Sửa đổi task

1. Mở Task Scheduler
2. Tìm task **"Weather ETL Daily"**
3. Click chuột phải → **"Properties"**
4. Sửa đổi các cấu hình cần thiết
5. Click **OK**

---

## 🐛 Xử lý lỗi

### Task không chạy

**Kiểm tra:**

1. Task có được **Enable** không?
2. Máy tính có đang bật lúc 7h sáng không?
3. File `run-etl-daily.bat` có tồn tại không?
4. Đường dẫn trong task có đúng không?

**Giải pháp:**

- Chạy thủ công để xem lỗi cụ thể
- Kiểm tra tab **"History"** để xem log lỗi
- Kiểm tra quyền truy cập file và thư mục

### Task chạy nhưng ETL lỗi

**Kiểm tra:**

1. Database có đang chạy không?
2. Kết nối database có đúng không?
3. API có hoạt động không?

**Giải pháp:**

- Chạy thủ công `npm run run:etl` để xem lỗi chi tiết
- Kiểm tra file config `config-dev.xml`
- Kiểm tra logs trong database

### Task chạy nhưng không có dữ liệu

**Kiểm tra:**

1. API có trả về dữ liệu không?
2. Transform có thành công không?
3. Load to datawarehouse có lỗi không?

**Giải pháp:**

- Chạy từng bước thủ công để kiểm tra:
  ```bash
  npm run run:fetch
  npm run run:load
  npm run run:transform
  npm run run:load-dw
  ```

---

## 📝 Thay đổi lịch chạy

Nếu muốn thay đổi thời gian chạy (ví dụ: 8h sáng thay vì 7h):

1. Mở Task Scheduler
2. Tìm task **"Weather ETL Daily"**
3. Click chuột phải → **"Properties"**
4. Tab **Triggers** → Click **"Edit..."**
5. Sửa **Time** thành `08:00:00`
6. Click **OK** → **OK**

---

## 💡 Tips

- **Test trước**: Luôn test bằng cách chạy thủ công trước khi để tự động
- **Kiểm tra logs**: Thường xuyên kiểm tra tab History để đảm bảo task chạy thành công
- **Backup config**: Lưu backup file config trước khi thay đổi
- **Monitor database**: Kiểm tra database thường xuyên để đảm bảo dữ liệu được load đúng

---

## 📞 Hỗ trợ

Nếu gặp vấn đề, kiểm tra:

1. File `run-etl-daily.bat` có chạy được thủ công không?
2. Task Scheduler có quyền chạy file không?
3. Database và API có hoạt động không?

---

**Chúc bạn setup thành công! **
