import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/page/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Discover Products",
      "desc":
          "Explore thousands of products from the best brands at unbeatable prices.",
      "icon": "search_rounded",
    },
    {
      "title": "Easy Payment",
      "desc":
          "Secure and seamless payment options for a worry-free shopping experience.",
      "icon": "account_balance_wallet_rounded",
    },
    {
      "title": "Fast Delivery",
      "desc": "Get your orders delivered to your doorstep in record time.",
      "icon": "local_shipping_rounded",
    },
  ];

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'search_rounded':
        return Icons.search_rounded;
      case 'account_balance_wallet_rounded':
        return Icons.account_balance_wallet_rounded;
      case 'local_shipping_rounded':
        return Icons.local_shipping_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        235,
        235,
        245,
      ), // Cleaned up background
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button with Fade Animation
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _currentPage == _onboardingData.length - 1 ? 0.0 : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed:
                        _currentPage == _onboardingData.length - 1
                            ? null
                            : () => _completeOnboarding(context),
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  // This boolean checks if the current page is the one being viewed
                  bool isActive = _currentPage == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1. Icon Animation (Scale & Fade)
                        AnimatedScale(
                          scale: isActive ? 1.0 : 0.7,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: isActive ? 1.0 : 0.0,
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIcon(_onboardingData[index]['icon']!),
                                size: 100,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        // 2. Title Animation (Slide & Fade)
                        AnimatedPadding(
                          duration: const Duration(milliseconds: 600),
                          padding: EdgeInsets.only(top: isActive ? 0 : 40),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 600),
                            opacity: isActive ? 1.0 : 0.0,
                            child: Text(
                              _onboardingData[index]['title']!,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Lato',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 3. Description Animation (Delayed Fade)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: isActive ? 1.0 : 0.0,
                          child: Text(
                            _onboardingData[index]['desc']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                children: [
                  // Dot Indicators (Scaling effect)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Colors.blueAccent
                                  : Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Button with simple transition
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      shadowColor: Colors.blueAccent.withOpacity(0.4),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? "GET STARTED"
                            : "NEXT",
                        key: ValueKey(_currentPage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
