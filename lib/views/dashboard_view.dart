import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF7F2E9);
    const Color brandColor = Color(0xFFB84715);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADING
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'E-Recipe',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'OpenSans Bold',
                      color: brandColor,
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: brandColor,
                    child: const Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // SEARCH BAR
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'MOMO ',
                    hintStyle: const TextStyle(
                      fontFamily: 'OpenSans Regular',
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Icon(Icons.tune, color: brandColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  style: const TextStyle(fontFamily: 'OpenSans Regular'),
                ),
              ),
              const SizedBox(height: 24),

              // ALL, LUNCH, DINNER, BREAKFAST
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Chip 1: All
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: brandColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'All',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans Bold',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Chip 2: Breakfast
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Breakfast',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'OpenSans Regular',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Chip 3: Lunch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Lunch',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'OpenSans Regular',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Chip 4: Dinner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Dinner',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'OpenSans Regular',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Chef Specials Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Chef's Specials",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'OpenSans BOLD',
                    ),
                  ),
                  Text(
                    'VIEW ALL',
                    style: TextStyle(
                      color: brandColor,
                      fontSize: 12,
                      fontFamily: 'OpenSans SemiBold',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Chef's Specials 
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChefCard(
                        title: 'MACHA KHANE HOOO',
                        brandColor: brandColor,
                      ),
                      const SizedBox(width: 12),
                      _buildChefCard(
                        title: 'AYE PO BANAUNE',
                        brandColor: brandColor,
                      ),
                       const SizedBox(width: 12),
                      _buildChefCard(
                        title: 'AYE PO BANAUNE',
                        brandColor: brandColor,
                      ),
                    
                      
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: brandColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREMIUM LENU HOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'OpenSans Bold',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'GET ACCESS TO MORE RECIPES',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'OpenSans Regular',
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: brandColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'GET PREMIUM',
                        style: TextStyle(fontFamily: 'OpenSans SemiBold'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Trending
              const Text(
                'EASY TOO COOK NOW',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'OpenSans Bold',
                ),
              ),
              const SizedBox(height: 16),

              // Row 1
              Row(
                children: [
                  Expanded(
                    child: _buildTrendingCard(
                      title: 'TARKARI',
                      emoji: '🍲',
                      brandColor: brandColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTrendingCard(
                      title: 'MOMO',
                      emoji: '🥟',
                      brandColor: brandColor,
                    ),
                  ),
                  
                ],
              ),
              const SizedBox(height: 16),

              // Row 2
              Row(
                children: [
                  Expanded(
                    child: _buildTrendingCard(
                      title: 'BHAT',
                      emoji: '🍚',
                      brandColor: brandColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontFamily: 'OpenSans SemiBold'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'OpenSans Regular'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // Chef card 
  Widget _buildChefCard({
    required String title,
    required Color brandColor,
  }) {
    return Container(
      width: 160, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE8D9CC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(child: Icon(Icons.restaurant, size: 40, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'OpenSans Bold',
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Trending card 
  Widget _buildTrendingCard({
    required String title,
    required String emoji,
    required Color brandColor,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE0D5C8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'OpenSans Bold',
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}