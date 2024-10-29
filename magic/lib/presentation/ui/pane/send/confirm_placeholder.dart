import 'package:flutter/material.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/services/services.dart';

class ConfirmContentPlaceholder extends StatefulWidget {
  const ConfirmContentPlaceholder({super.key});

  @override
  State<ConfirmContentPlaceholder> createState() =>
      _ConfirmContentPlaceholderState();
}

class _ConfirmContentPlaceholderState extends State<ConfirmContentPlaceholder>
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: screen.pane.midHeight,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 42),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular placeholder for CurrencyIdenticon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.frontItem
                                .withOpacity(_animation.value),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Rounded placeholder for address
                        Expanded(
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.frontItem
                                  .withOpacity(_animation.value),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Placeholder for Fee
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: _PlaceholderItem(animation: _animation),
              ),
              const Divider(height: 1, indent: 0, endIndent: 0),
              // Placeholder for Amount
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: _PlaceholderItem(animation: _animation),
              ),
              const SizedBox(height: 8),
              // Placeholder for Send button
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 12, bottom: 24),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey[800]!.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'SEND',
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
      },
    );
  }
}

class _PlaceholderItem extends StatelessWidget {
  final Animation<double> animation;

  const _PlaceholderItem({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.frontItem.withOpacity(animation.value),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
