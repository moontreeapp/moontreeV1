import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:magic/services/services.dart';

class PoolContentPlaceholder extends StatefulWidget {
  const PoolContentPlaceholder({super.key});

  @override
  State<PoolContentPlaceholder> createState() => _PoolContentPlaceholderState();
}

class _PoolContentPlaceholderState extends State<PoolContentPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.67, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screen.pane.midHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Placeholder for Amount TextField
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _PlaceholderItem(animation: _animation),
          ),
          // Placeholder for Join button
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[800]!.withOpacity(_animation.value),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  'JOIN POOL',
                  style: AppText.button1.copyWith(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderItem extends StatelessWidget {
  final Animation<double> animation;

  const _PlaceholderItem({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.frontItem.withOpacity(animation.value),
            borderRadius: BorderRadius.circular(28 * 100),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Amount',
              style: AppText.body1.copyWith(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
