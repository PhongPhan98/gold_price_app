# Gold Price App

Ứng dụng Flutter theo dõi giá vàng Việt Nam từ nhiều thương hiệu khác nhau, đang được phát triển theo hướng sản phẩm có thể thương mại hóa.

## Current Providers
- Bảo Tín Minh Châu
- Mi Hồng
- Doji

## Core Product Direction
Mục tiêu hiện tại không chỉ là xem giá vàng, mà là xây dựng một sản phẩm có thể tạo doanh thu từ người dùng trả phí.

### Free Tier
- Xem giá vàng theo từng thương hiệu
- Home summary và quick compare cơ bản
- Ghim nguồn ưu tiên
- 1 cảnh báo giá miễn phí
- Làm mới dữ liệu thủ công

### Premium Tier (current plan)
- Nhiều cảnh báo hơn
- Compare nâng cao hơn
- Insight / recommendation tốt hơn
- Lịch sử giá và xu hướng (giai đoạn sau)
- Trải nghiệm ưu tiên, hướng tới khả năng subscription thật sau này

## Current Features
- Xem giá mua vào / bán ra theo từng thương hiệu
- Làm mới dữ liệu thủ công
- Hiển thị thời gian cập nhật
- Trạng thái lỗi và thử lại khi tải dữ liệu thất bại
- Home summary với compare entry point
- Favorite provider persistence
- Compare screen MVP
- Price alerts screen
- Premium paywall skeleton

## Project Structure
```text
lib/
  core/
    models/
    network/
    utils/
    widgets/
  features/
    alerts/
    compare/
    gold_prices/
      data/services/
      presentation/
    home/
      data/
      models/
      presentation/
    premium/
```

## Premium Product Plan
### Stage 1 — Premium foundation
- Premium status model
- Local premium storage
- Paywall screen
- Premium entry points
- Basic alert upgrade flow

### Stage 2 — Real free vs premium rules
- 1 free alert max
- Additional alerts require premium
- More visible premium benefits and lock messaging
- Stronger paywall entry points

### Stage 3 — Alerts as conversion engine
- Better alerts management
- Alert edit/delete
- Better premium upsell around retention use cases

### Stage 4 — Advanced compare
- Better compare experience
- Advanced sort/filter later
- Premium-only compare improvements

### Stage 5 — Payment integration
- Monthly / yearly plans
- Real subscription engine later

## Development Status
### Done
- Phase 1: Refactor codebase into cleaner feature structure
- Phase 2: Improve UX and reliability
- Phase 3: Product polish and home summary improvements
- Phase 4: Release checklist and stronger test baseline
- Phase 5 (partial): compare MVP, favorites persistence, alerts architecture, premium skeleton

### Current Focus
- real free-vs-premium rules
- stronger conversion UX
- premium-ready product structure

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
