import 'package:magic/presentation/ui/pane/pool/page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubits.dart';
import 'package:flutter/material.dart';

class Pool extends StatelessWidget {
  const Pool({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PoolCubit, PoolState>(
        builder: (BuildContext context, PoolState state) =>
            state.transitionWidgets(
          state,
          onEntering: const PoolPage(),
          onEntered: const PoolPage(),
          onExiting: const SizedBox.shrink(),
          onExited: const SizedBox.shrink(),
        ),
      );
}
