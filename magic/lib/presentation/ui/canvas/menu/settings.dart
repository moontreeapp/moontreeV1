import 'package:flutter/material.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/services/services.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/login/native.dart';
import 'package:magic/presentation/ui/welcome/addresses.dart';
import 'package:magic/presentation/ui/welcome/backup.dart';
import 'package:magic/presentation/ui/welcome/import.dart';
import 'package:magic/presentation/ui/welcome/wallets.dart';
import 'package:magic/presentation/ui/welcome/pair_with_chrome.dart';

class DifficultyItem extends StatefulWidget {
  final DifficultyMode mode;

  const DifficultyItem({super.key, required this.mode});

  @override
  DifficultyItemState createState() => DifficultyItemState();
}

class DifficultyItemState extends State<DifficultyItem> {
  bool _isShrunk = false;

  void _toggleShrink() {
    setState(() {
      _isShrunk = !_isShrunk;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isShrunk = !_isShrunk;
      });
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          _toggleShrink();
          cubits.menu.toggleDifficulty();
        },
        onLongPress: () {
          _toggleShrink();
          cubits.menu.update(mode: DifficultyMode.dev);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: _isShrunk ? screen.width * 0.67 : screen.width,
          height: screen.menu.itemHeight,
          color: Colors.transparent,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(widget.mode.icon, color: Colors.white),
            const SizedBox(width: 16),
            Text('Mode: ${widget.mode.name}',
                style: AppText.h2.copyWith(color: Colors.white)),
          ]),
        ),
      );
}

class NotificationItem extends StatelessWidget {
  final MenuState state;

  const NotificationItem({super.key, required this.state});

  @override
  Widget build(BuildContext context) => MenuItem(
        icon: state.setting
            ? Icons.notifications_on_rounded
            : Icons.notifications_off_rounded,
        text: 'Notification: ${state.setting ? 'On' : 'Off'}',
        onTap: cubits.menu.toggleSetting,
      );
}

class BackupItem extends StatelessWidget {
  const BackupItem({super.key});

  @override
  Widget build(BuildContext context) => MenuItem(
        icon: Icons.key_sharp,
        text: 'Backup',
        onTap: () => cubits.welcome.update(
          active: true,
          allowScreenshot: false,
          child: LoginNative(
            onFailure: () => cubits.welcome
                .update(active: false, child: const SizedBox.shrink()),
            child: const BackupPage(),
          ),
        ),
      );
}

class ImportItem extends StatelessWidget {
  const ImportItem({super.key});

  @override
  Widget build(BuildContext context) => MenuItem(
        icon: Icons.add_circle_rounded,
        text: 'Import',
        onTap: () => cubits.welcome.update(
          active: true,
          allowScreenshot: false,
          child: const ImportPage(),
        ),
      );
}

class WalletsItem extends StatelessWidget {
  const WalletsItem({super.key});

  @override
  Widget build(BuildContext context) => MenuItem(
        icon: Icons.wallet_rounded,
        text: 'Wallets',
        onTap: () => cubits.welcome.update(
          active: true,
          allowScreenshot: false,
          child: LoginNative(
            onFailure: () => cubits.welcome.update(
              active: false,
              child: const SizedBox.shrink(),
            ),
            child: const WalletsPage(),
          ),
        ),
      );
}

class AddressesItem extends StatelessWidget {
  const AddressesItem({super.key});

  @override
  Widget build(BuildContext context) => MenuItem(
        icon: Icons.menu_open_rounded,
        text: 'Addresses',
        onTap: () => cubits.welcome.update(
          active: true,
          allowScreenshot: false,
          child: const AddressesPage(),
        ),
      );
}

class PairWithChromeItem extends StatelessWidget {
  const PairWithChromeItem({super.key});

  @override
  Widget build(BuildContext context) => MenuItem(
        icon: Icons.public,
        text: 'Pair with chrome',
        onTap: () => cubits.welcome.update(
          active: true,
          child: const PairWithChromePage(),
        ),
      );
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screen.menu.itemHeight,
        width: screen.width,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Text(text, style: AppText.h2.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
