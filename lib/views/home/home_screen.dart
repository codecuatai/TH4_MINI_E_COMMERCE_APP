import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentBanner = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().fetchProducts();
    });
  }

  void _onScroll() {
    if (_searchQuery.isNotEmpty) return;

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

    final banners = _buildBanners();

    // ✅ FILTER LOGIC (search + category)
    final filteredProducts = productController.products.where((product) {
      final query = _searchQuery.toLowerCase();
      final title = product.title.toLowerCase();

      final matchSearch = title.contains(query);

      final matchCategory = _selectedCategory == 'All'
          ? true
          : product.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchSearch && matchCategory;
    }).toList();

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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: 160,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentBanner = index;
                            });
                          },
                        ),
                        items: banners,
                      ),
                    ),
                    AnimatedSmoothIndicator(
                      activeIndex: _currentBanner,
                      count: banners.length,
                      effect: const ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Color(0xFF667eea),
                        dotColor: Colors.grey,
                      ),
                      onDotClicked: (index) {
                        _carouselController.animateToPage(index);
                      },
                    ),
                  ],
                ),
              ),

              // ===== CATEGORY FILTER (ICON) =====
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategory('Tất cả', Icons.category, 'All'),
                      _buildCategory(
                        'Thời trang',
                        Icons.checkroom,
                        "men's clothing",
                      ),
                      _buildCategory('Điện tử', Icons.devices, "electronics"),
                      _buildCategory('Mỹ phẩm', Icons.face, "women's clothing"),
                      _buildCategory('Gia dụng', Icons.kitchen, "jewelery"),
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

              // ===== EMPTY =====
              if (filteredProducts.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Không tìm thấy sản phẩm'),
                    ),
                  ),
                )
              else
                // ===== GRID =====
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < filteredProducts.length) {
                          final product = filteredProducts[index];
                          return ProductCard(product: product);
                        } else {
                          return const LoadingShimmer();
                        }
                      },
                      childCount:
                          productController.hasMore && _searchQuery.isEmpty
                          ? filteredProducts.length + 2
                          : filteredProducts.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
        'TH4 - Nhóm 6',
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
          icon: const Icon(Icons.receipt_long, color: Colors.black),
          tooltip: 'Đơn hàng',
          onPressed: () {
            Navigator.pushNamed(context, '/orders');
          },
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
    );
  }

  // ================= BANNERS =================
  List<Widget> _buildBanners() {
    final banners = [
      'https://images.unsplash.com/photo-1483985988355-763728e1935b',
      'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519',
      'https://images.unsplash.com/photo-1607082349566-187342175e2f',
    ];

    return banners
        .map(
          (url) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              '$url?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        )
        .toList();
  }

  // ================= CATEGORY =================
  Widget _buildCategory(String label, IconData icon, String category) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isSelected
                  ? Colors.deepPurple
                  : Colors.grey[200],
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.deepPurple : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
