# Triển khai hệ thống Theme và Audit Dark Mode

Kế hoạch này sẽ làm cho Dark Mode hoạt động đúng đắn trên tất cả các màn hình, tuân thủ nguyên tắc không sử dụng màu cứng (hardcoded colors) cho các thành phần UI thông thường.

## User Review Required

> [!IMPORTANT]
> - Vui lòng xem xét các thay đổi đối với `AppTheme` và các file widget cụ thể. 
> - Xác nhận xem các màu theo `colorScheme` có đúng với thiết kế mong đợi của bạn khi chuyển sang giao diện tối chưa trước khi tiến hành thực thi code.
> - Bất kỳ tuỳ chỉnh nào khác về màu trong các widget như màu Gradient của `FocusSummaryCards` và màu pha Pomodoro có cần được loại bỏ luôn không (tôi sẽ thay bằng màu từ `colorScheme` như bạn mô tả).

## Proposed Changes

---

### Cấu hình Theme

#### [MODIFY] [app_theme.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/core/theme/app_theme.dart)
- Xóa bỏ class `AppColors` do đã được chuyển riêng ra `app_colors.dart`.
- Viết lại toàn bộ `AppTheme`:
  - `lightTheme`: Sử dụng `ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4), brightness: Brightness.light)`. Các phần tử (Scaffold, AppBar, Card, Text, ListTile, Switch, NavigationBar) đều sẽ dùng đúng các thuộc tính từ `colorScheme`.
  - `darkTheme`: Sử dụng `ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4), brightness: Brightness.dark)` và để ColorScheme tự động nội suy màu tương thích. Không hardcode bất kỳ màu nào (vd: không sử dụng `colorScheme.surfaceContainerLowest` cứng như trước đó).

---

### Eisenhower Matrix

#### [MODIFY] [quadrant_widget.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/features/eisenhower_matrix/presentation/widgets/quadrant_widget.dart)
- Khung background giữ nguyên định dạng màu sắc tĩnh (`quadrantLightColor`) để giữ logic phân loại Eisenhower. Tuy nhiên, `Text` phía trên Header (nhãn Q1, Q2, Q3, Q4) sẽ được áp dụng `Colors.white` hoặc màu tương phản cao (chứa text color) để có thể quan sát rõ khi `quadrantLightColor` quá dị biệt với Theme tối.

#### [MODIFY] [task_card_widget.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/features/eisenhower_matrix/presentation/widgets/task_card_widget.dart)
- Màu thẻ: `Theme.of(context).colorScheme.surface`.
- Title: `Theme.of(context).colorScheme.onSurface`.
- Task hoàn thành (Cross line): `Theme.of(context).colorScheme.onSurface.withOpacity(0.5)`.

#### [MODIFY] [add_task_dialog.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/features/eisenhower_matrix/presentation/widgets/add_task_dialog.dart)
- Các field: Background bằng `colorScheme.surface`, còn Label text/nội dung dùng `colorScheme.onSurface`.

---

### Pomodoro Timer

#### [MODIFY] [circular_timer_widget.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/features/pomodoro_timer/presentation/widgets/circular_timer_widget.dart)
- Arc background (`trackColor`): Thay `color.withOpacity(0.1)` bằng `colorScheme.surfaceVariant`.
- Progress Arc: Dùng `colorScheme.primary` (thay vì dùng màu cố định đỏ/xanh/tím như trước đó).
- Text đếm ngược: Dùng `colorScheme.onBackground` để luôn có độ tương phản đúng khi đổi mode.

#### [MODIFY] [phase_indicator_widget.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/features/pomodoro_timer/presentation/widgets/phase_indicator_widget.dart)
- Pill khi Active: Bền màu `colorScheme.primaryContainer`, chữ `colorScheme.onPrimaryContainer`.
- Pill khi Inactive: Giao diện `colorScheme.surfaceVariant`, chữ `colorScheme.onSurfaceVariant`.

---

### Statistics Focus & Chart

#### [MODIFY] [focus_summary_cards.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/features/statistics/presentation/widgets/focus_summary_cards.dart)
- Thay đổi `Container` card thành màu `colorScheme.surfaceVariant` mờ đi.
- Label: `colorScheme.onSurfaceVariant`.
- Value (Số phút/Pomodoro): `colorScheme.onBackground`.

#### [MODIFY] [pomodoro_bar_chart.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/features/statistics/presentation/widgets/pomodoro_bar_chart.dart)
- Cột trong biểu đồ: Gán cứng `colorScheme.primary` (xóa cái hàm Gradient màu mè cứng nhắc chệch tông).
- Thay thế các Text Label (T2-CN, số lưới Y, title "Tuần này") thành `colorScheme.onBackground` và cấu trúc lưới.

---

### Settings

#### [MODIFY] [settings_page.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/features/settings/presentation/pages/settings_page.dart)
- Rà soát các vùng cứng như `Container`, `CircleAvatar` để thay `backgroundColor` bằng những thuộc tính kế thừa của `colorScheme`.
- Cập nhật `SwitchListTile` để lấy biến `value: state.isDarkMode` trực tiếp từ state thay vì thông qua final variable (theo đúng yêu cầu).

#### [MODIFY] [main.dart](file:///d:/tailieu/hk2-n%C4%83m4/TTTN/DuAN/smart_productivity_booster/lib/main.dart)
- Thêm Comment bằng tiếng Việt giải thích lý do tại sao `SettingsBloc` (và các BlocProvider) lại bắt buộc phải đặt BÊN NGOÀI `MaterialApp`.
- Đảm bảo `MaterialApp` được wrap bởi `BlocBuilder` để nhận biến `isDark` trực tiếp và gán `themeMode`. Mặc dù logic này đã được thiết lập đúng, nhưng sẽ audit lại comment để làm nổi bật.

---

## Giải thích về thuộc tính `onBackground` và `Colors.black`

`Colors.black` là một màu tĩnh không đổi. `ColorScheme` có bộ cặp tương phản:
- Ở chế độ **Light**: `surface` (trắng xám) → `onSurface` / `onBackground` đi kèm là **Đen/Tối màu**.
- Ở chế độ **Dark**: `surface` (đen xám) → `onSurface` / `onBackground` được Flutter tự đảo ngược thành **Trắng/Sáng màu**.

Bất kỳ Text nào sử dụng `colorScheme.onBackground` sẽ luôn nổi bật một cách tự động khi độ sáng thay đổi, mà không cần viết lệnh `if-else` nào cả.

## Open Questions

- Bỏ tính năng gradient cho `PomodoroBarChart` và đổi sang Solid Color `colorScheme.primary`, hay bạn muốn giữ gradient nhưng sinh ra từ 2 tông sáng-tối của `primary`?
- Các nút Pomodoro Phase Pill (Làm việc, Nghỉ) có chuyển hoàn toàn sang primaryContainer không, hay vẫn cần phân biệt bằng 3 màu (Đỏ, Xanh nước biển, Tím)?

## Verification Plan

- Khởi chạy lại ứng dụng trên Device/Web.
- Bật Switch đổi `Dark Mode` trong tab **Cài đặt**.
- Qua lại mọi tab (Eisenhower, Pomodoro, Thống kê) để xác nhận text rõ nét và nền tương phản, không có khối màu tĩnh phá vỡ giao diện.
