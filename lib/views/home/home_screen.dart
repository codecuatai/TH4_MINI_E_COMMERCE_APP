import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load dữ liệu lần đầu
    Future.microtask(() {
      context.read<ProductController>().fetchProducts();
    });
  }

  void _onScroll() {
    final productController = context.read<ProductController>();

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        productController.hasMore &&
        !productController.isLoading) {
      productController.fetchProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();
    final cartController = context.watch<CartController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await productController.refreshProducts();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(cartController),

              // ===== CAROUSEL =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 160,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: _buildBanners(),
                  ),
                ),
              ),

              // ===== CATEGORY =====
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategory('Thời trang', Icons.checkroom),
                      _buildCategory('Điện tử', Icons.devices),
                      _buildCategory('Mỹ phẩm', Icons.face),
                      _buildCategory('Gia dụng', Icons.kitchen),
                      _buildCategory('Sách', Icons.menu_book),
                    ],
                  ),
                ),
              ),

              // ===== TITLE =====
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Daily Discover',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // ===== PRODUCT GRID =====
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < productController.products.length) {
                        final product = productController.products[index];
                        return ProductCard(product: product);
                      } else {
                        return const LoadingShimmer();
                      }
                    },
                    childCount: productController.hasMore
                        ? productController.products.length + 2
                        : productController.products.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= APP BAR =================
  Widget _buildAppBar(CartController cartController) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 1,
      expandedHeight: 120,

      title: const Text(
        'TH4 - Nhóm X',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
            if (cartController.items.isNotEmpty)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${cartController.items.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () async {
            await context.read<AuthController>().logout();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),
      ],

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= BANNERS =================
  List<Widget> _buildBanners() {
    final banners = [
      'https://picsum.photos/400/200',
      'https://picsum.photos/401/200',
      'https://picsum.photos/402/200',
    ];

    return banners
        .map(
          (url) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        )
        .toList();
  }

  // ================= CATEGORY =================
  Widget _buildCategory(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 22, child: Icon(icon)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
