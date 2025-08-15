import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spyai/screens/chat.dart';
import 'package:spyai/screens/recording.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> with TickerProviderStateMixin {
  final pages = [RecordingScreen(), ChatScreen()];
  int index = 0;
  late AnimationController _animationController;
  late AnimationController _subtleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _subtleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
    _subtleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subtleController.dispose();
    super.dispose();
  }

  void _selectPage(int newIndex) {
    setState(() {
      index = newIndex;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1525),
      
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F1B2C),
                Color(0xFF0A1525),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _subtleController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Color.lerp(
                          const Color(0xFF1E3A5F).withOpacity(0.5),
                          const Color(0xFF2E5A8F).withOpacity(0.8),
                          _subtleController.value,
                        )!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A5F).withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Text(
                      "SPY AI",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF7BA7D9),
                        letterSpacing: 3,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      
      bottomNavigationBar: Container(
        height: 85,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F1B2C).withOpacity(0.9),
              const Color(0xFF1A2B3D).withOpacity(0.9),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF2E5A8F).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, FontAwesomeIcons.userSecret, "RECORD"),
            _buildNavItem(1, Icons.psychology_outlined, "ANALYZE"),
          ],
        ),
      ),
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1525),
              Color(0xFF061018),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: pages[index],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int itemIndex, IconData icon, String label) {
    bool isSelected = index == itemIndex;
    
    return GestureDetector(
      onTap: () => _selectPage(itemIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFF1E3A5F).withOpacity(0.6),
                    const Color(0xFF2E5A8F).withOpacity(0.4),
                  ],
                )
              : null,
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF4A7BAD).withOpacity(0.5),
                  width: 1,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E3A5F).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF7BA7D9)
                    : const Color(0xFF4A6B8A),
                size: isSelected ? 26 : 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                color: isSelected
                    ? const Color(0xFF7BA7D9)
                    : const Color(0xFF4A6B8A),
                letterSpacing: 1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
