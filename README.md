# Gold Price App

Ứng dụng Flutter theo dõi giá vàng Việt Nam từ nhiều thương hiệu khác nhau.

## Current Providers
- Bảo Tín Minh Châu
- Mi Hồng
- Doji

## Current Features
- Xem giá mua vào / bán ra theo từng thương hiệu
- Làm mới dữ liệu thủ công
- Hiển thị thời gian cập nhật
- Trạng thái lỗi và thử lại khi tải dữ liệu thất bại
- Giao diện home có mô tả và thẻ điều hướng rõ ràng hơn

## Project Structure
```text
lib/
  core/
    models/
    network/
    utils/
    widgets/
  features/
    gold_prices/
      data/services/
      presentation/
    home/
      data/
      models/
      presentation/
```

## Development Status
### Done
- Phase 1: Refactor codebase into cleaner feature structure
- Phase 2: Improve UX and reliability

### In Progress
- Phase 3: Product polish, onboarding, and home summary improvements

### Blockers
- Android SDK is still required before full Android build validation can complete

## Local Development
Use the locally installed Flutter SDK:

```bash
export PATH="/home/phongkoika/.openclaw/tools/flutter/bin:$PATH"
cd /home/phongkoika/.openclaw/workspace/projects/gold_price_app
flutter pub get
flutter analyze
flutter test
```

## Android Build Notes
Java is installed, but Android SDK still needs to be configured.
Once Android SDK is available, run:

```bash
flutter doctor -v
flutter build apk --debug
```

## Next Product Direction
- home-screen quick summaries
- compare providers
- favorites / pinned providers
- auto refresh options
- better responsive mobile layout
- improved release and onboarding docs
