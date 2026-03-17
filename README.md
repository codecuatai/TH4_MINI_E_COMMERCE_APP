# 🛒 Flutter E-commerce App (TH4)

## 📌 Giới thiệu

Flutter E-commerce App (TH4) là ứng dụng thương mại điện tử di động hoàn chỉnh, xây dựng bằng Flutter theo kiến trúc MVC nghiêm ngặt, sử dụng Firebase Authentication, Cloud Firestore, Provider (state management) và tích hợp FakeStore API. Dự án được phát triển cho bài tập lớn TH4, hướng tới trải nghiệm thực tế, code sạch, dễ mở rộng và UI/UX hiện đại.

---

## 🚀 Tính năng chính

- 🔐 Đăng ký / Đăng nhập (Firebase Auth)
- 🛍️ Hiển thị sản phẩm từ API (FakeStore API)
- 🔎 Tìm kiếm & xem chi tiết sản phẩm
- ➕ Thêm vào giỏ hàng
- 🛒 Quản lý giỏ hàng (checkbox chọn/xóa, tính tổng tiền)
- 🧾 Đặt hàng & xác nhận đơn
- ☁️ Lưu đơn hàng lên Cloud Firestore
- ♻️ Pull to refresh, infinite scroll sản phẩm
- 🏷️ Badge số lượng giỏ hàng realtime

---

## 🏗️ Kiến trúc

Ứng dụng tuân thủ mô hình **MVC**:

- **Models**: Định nghĩa cấu trúc dữ liệu (Product, CartItem, Order, User)
- **Views**: Chỉ chứa UI, nhận dữ liệu qua Provider, không chứa business logic
- **Controllers**: Quản lý trạng thái, xử lý logic, giao tiếp với Service/API, expose dữ liệu cho View qua Provider
- **Services**: Tầng giao tiếp với Firebase, REST API, xử lý dữ liệu từ backend

**Provider** đóng vai trò quản lý trạng thái toàn cục, giúp View tự động cập nhật khi dữ liệu thay đổi.

---

## 📂 Cấu trúc thư mục

```
lib/
├── models/         # Định nghĩa model: product_model.dart, cart_item_model.dart, ...
├── views/          # UI: home_screen.dart, cart_screen.dart, login_screen.dart, ...
│   ├── home/
│   ├── cart/
│   ├── auth/
│   ├── checkout/
│   ├── orders/
│   └── product_detail/
├── controllers/    # Quản lý logic: product_controller.dart, cart_controller.dart, ...
├── services/       # Kết nối API, Firebase: api_service.dart, auth_service.dart, ...
├── widgets/        # Widget dùng lại: product_card.dart, loading_shimmer.dart, ...
└── main.dart       # Điểm khởi động ứng dụng
```

---

## 🔥 Công nghệ sử dụng

- **Flutter** (>=3.10.7)
- **Firebase Authentication**
- **Cloud Firestore**
- **Provider** (state management)
- **REST API** (FakeStore API)
- **Google Fonts, Shared Preferences, HTTP, Carousel Slider**

---

## ⚙️ Cài đặt & chạy

```bash
# 1. Cài dependencies
flutter pub get

# 2. Cấu hình Firebase (đã có sẵn google-services.json cho Android, GoogleService-Info.plist cho iOS)

# 3. Chạy ứng dụng
flutter run
```

---

## 📸 Demo

- **Màn hình đăng nhập/đăng ký:** Xác thực qua Firebase, kiểm tra hợp lệ, báo lỗi realtime.
- **Trang chủ:** SliverAppBar sticky, search bar, carousel slider, danh mục, grid sản phẩm, pull-to-refresh, infinite scroll.
- **Chi tiết sản phẩm:** Ảnh lớn, mô tả, giá, nút thêm vào giỏ.
- **Giỏ hàng:** Checkbox chọn/xóa, badge số lượng, tính tổng tiền, chuyển sang đặt hàng.
- **Đặt hàng:** Xác nhận, lưu đơn lên Firestore, xem lịch sử đơn hàng.

---

## 👨‍💻 Tác giả

- **Tên sinh viên:** [Điền tên bạn tại đây]
- **Nhóm:** [TH4 - Nhóm X]

---

## 🛠️ Công nghệ sử dụng

- **Flutter** (framework giao diện)
- **Dart** (ngôn ngữ lập trình)
- **Provider** (quản lý trạng thái)
- **Firebase**
  - Authentication (xác thực)
  - Cloud Firestore (cơ sở dữ liệu)
- **FakeStore API** (dữ liệu sản phẩm)
- **SharedPreferences** (lưu trữ cục bộ)
- **intl** (định dạng tiền tệ)
- **carousel_slider** (slider banner)

---

## 🏗️ Kiến trúc dự án

Dự án tuân thủ chặt chẽ mô hình **MVC**:

```
lib/
├── models/        # Lớp dữ liệu (Product, CartItem, Order, User)
├── views/         # Giao diện (Home, Auth, Cart, Product Detail...)
├── controllers/   # Logic nghiệp vụ, state (ChangeNotifier)
├── services/      # API & Firebase
├── widgets/       # Widget tái sử dụng
├── utils/         # Tiện ích (format, hằng số)
└── main.dart      # Khởi tạo app, MultiProvider, routes
```

- **Không có logic nghiệp vụ trong views**
- **Không có code UI trong controllers**
- **Controllers kế thừa ChangeNotifier**
- **Provider** để quản lý trạng thái

---

## ✨ Tính năng nổi bật

- **Xác thực người dùng**
  - Đăng nhập/Đăng ký với Firebase
  - Xử lý lỗi (sai mật khẩu, email đã dùng...)
- **Trang chủ**
  - SliverAppBar có tìm kiếm
  - Banner carousel tự động
  - Lưới danh mục
  - Lưới sản phẩm (infinite scroll, pull-to-refresh)
- **Chi tiết sản phẩm**
  - Hero animation cho ảnh
  - Slider ảnh
  - Biến thể (size/màu)
  - Mô tả mở rộng/thu gọn
  - Thêm vào giỏ & Mua ngay (BottomSheet)
- **Giỏ hàng**
  - Checkbox từng sản phẩm, chọn tất cả
  - Vuốt để xóa
  - Tăng/giảm số lượng
  - Tính tổng realtime (chỉ sản phẩm được chọn)
  - Lưu cục bộ bằng SharedPreferences
- **Thanh toán**
  - Nhập địa chỉ
  - Chọn phương thức (COD, Momo)
  - Lưu đơn hàng lên Firestore
  - Thông báo thành công
- **Lịch sử đơn hàng**
  - Tab trạng thái (chờ xác nhận, đang giao, đã giao, đã hủy)
  - Lấy dữ liệu từ Firestore
- **Lưu trữ dữ liệu**
  - Giỏ hàng lưu cục bộ
  - Đồng bộ Firestore sau đăng nhập (bonus)

---

## 📝 Hướng dẫn cài đặt

1. **Clone dự án**
   ```bash
   git clone https://github.com/your-username/flutter-ecommerce-mvc.git
   cd flutter-ecommerce-mvc
   ```
2. **Cài đặt thư viện**
   ```bash
   flutter pub get
   ```
3. **Cấu hình Firebase**
   - Tạo project Firebase
   - Thêm app Android/iOS
   - Tải `google-services.json`/`GoogleService-Info.plist` vào đúng thư mục
   - Bật Authentication (Email/Password) và Firestore
4. **Chạy ứng dụng**
   ```bash
   flutter run
   ```

---

## 📸 Ảnh minh họa

> _Thêm ảnh chụp màn hình app tại đây_

|     Đăng nhập/Đăng ký      |         Trang chủ         |      Chi tiết sản phẩm       |         Giỏ hàng          |          Thanh toán           |          Đơn hàng           |
| :------------------------: | :-----------------------: | :--------------------------: | :-----------------------: | :---------------------------: | :-------------------------: |
| ![](screenshots/login.png) | ![](screenshots/home.png) | ![](screenshots/product.png) | ![](screenshots/cart.png) | ![](screenshots/checkout.png) | ![](screenshots/orders.png) |

---

## 💡 Giấy phép

Dự án phục vụ mục đích học tập, nghiên cứu. Bạn có thể sử dụng, chỉnh sửa cho cá nhân hoặc portfolio.

---

## 🙌 Cảm ơn

- Lấy cảm hứng UI/UX từ Shopee, Lazada
- Sử dụng [FakeStore API](https://fakestoreapi.com/)
- Xây dựng bởi ❤️ bởi nhóm của bạn
