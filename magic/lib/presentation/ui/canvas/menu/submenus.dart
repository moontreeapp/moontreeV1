import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/domain/concepts/side.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/canvas/menu/settings.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';
import 'package:magic/services/services.dart';
import 'package:magic/cubits/cubit.dart';

class SubMenus extends StatelessWidget {
  final MenuState state;
  const SubMenus({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screen.appbar.height),
            SizedBox(height: screen.canvas.midHeight),
            SubMenuItem(
                state: state,
                sub: SubMenu.help,
                delay: slideDuration * 1.25,
                alignment: Alignment.center,
                child: const HelpSubMenu()),
            SubMenuItem(
                state: state,
                sub: SubMenu.about,
                delay: slideDuration * 1.25,
                alignment: Alignment.center,
                child: const AboutSubMenu()),
            SubMenuItem(
                state: state,
                sub: SubMenu.settings,
                delay: slideDuration * 1,
                alignment: Alignment.topLeft,
                child: SettingsSubMenu(state: state)),
          ]);
}

class SubMenuItem extends StatelessWidget {
  final SubMenu sub;
  final MenuState state;
  final Duration delay;
  final Alignment alignment;
  final Widget child;
  const SubMenuItem({
    super.key,
    required this.state,
    required this.sub,
    required this.delay,
    required this.alignment,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (state.prior?.sub != sub && state.sub == sub)
            Container(
                width: screen.width - 32,
                alignment: alignment,
                //child: FadeIn(delay: fadeDuration * 4 * .5, child: child)),
                child: SlideSide(
                    delay: delay,
                    modifier: 32 / screen.width,
                    side: Side.right,
                    enter: true,
                    child: child)),
          if (state.prior?.sub == sub && state.sub != sub)
            Container(
                width: screen.width - 32,
                alignment: alignment,
                //child: FadeOut(child: child)),
                child: SlideSide(
                    side: Side.right,
                    modifier: 32 / screen.width,
                    enter: false,
                    child: child)),
        ],
      );
}

class SettingsSubMenu extends StatelessWidget {
  final MenuState state;

  const SettingsSubMenu({super.key, required this.state});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          current.active &&
          (previous.setting != current.setting ||
              previous.mode != current.mode),
      builder: (context, state) => SizedBox(
          width: screen.width - 32,
          child: Column(children: [
            DifficultyItem(mode: state.mode),
            //NotificationItem(state: state),
            if (cubits.menu.isInDevMode ||
                cubits.menu.isInHardMode ||
                cubits.menu.isInEasyMode)
              const FadeInItem(child: BackupItem()),
            if (cubits.menu.isInDevMode || cubits.menu.isInHardMode)
              const FadeInItem(child: ImportItem()),
            if (cubits.menu.isInDevMode) const FadeInItem(child: WalletsItem()),
            if (cubits.menu.isInDevMode)
              const FadeInItem(child: AddressesItem()),
            //if (cubits.menu.isInDevMode)
            //  const FadeInItem(child: PairWithChromeItem()), // CHROME NOT READY
          ])));

  //Text('Some Setting', style: AppText.h1.copyWith(color: Colors.white));
}

class FadeInItem extends StatefulWidget {
  final Widget child;
  const FadeInItem({super.key, required this.child});

  @override
  FadeInItemState createState() => FadeInItemState();
}

class FadeInItemState extends State<FadeInItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class HelpSubMenu extends StatelessWidget {
  const HelpSubMenu({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: screen.canvas.bottomHeight - 40 - 32,
      width: screen.width - 32,
      child:
          const Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        LinkOutButton(
            name: 'Magic',
            logo: 'assets/logos/discord.png',
            url: 'https://discord.gg/cGDebEXgpW'),
        SizedBox(height: 16),
        LinkOutButton(
            name: 'Brock Wood',
            logo: 'assets/logos/x.png',
            url: 'https://x.com/br0ck_w00d'),
        SizedBox(height: 16),
        LinkOutButton(
            name: 'Jordan Miller',
            logo: 'assets/logos/x.png',
            url: 'https://x.com/jordanmiller333'),
      ]));
}

class AboutSubMenu extends StatelessWidget {
  const AboutSubMenu({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: screen.canvas.bottomHeight - 40 - 32,
      width: screen.width - 32,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const LinkOutButton(
            name: 'Magic',
            logo: 'assets/logos/x.png',
            url: 'https://x.com/MagicWalletApp'),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          //Text('connection status: ${cubits.app.state.connection.name}',
          //    textAlign: TextAlign.center,
          //    style: AppText.body2.copyWith(color: Colors.white)),
          Text('version 1.8.1-alpha',
              textAlign: TextAlign.center,
              style: AppText.body2.copyWith(color: Colors.white)),
        ])
      ]));
}

class LinkOutButton extends StatelessWidget {
  final String url;
  final String name;
  final String logo;
  const LinkOutButton({
    super.key,
    required this.url,
    required this.name,
    required this.logo,
  });

  void _launchURL() async {
    //const url = 'https://x.com/MagicWalletApp';
    //if (await canLaunchUrlString(url)) {
    await launchUrl(Uri.parse(url));
    //} else {
    //  throw 'Could not launch $url';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screen.width * .53,
      child: ElevatedButton(
        onPressed: _launchURL,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.front,
          foregroundColor: Colors.white,
          //side: const BorderSide(color: Colors.white, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              logo,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
