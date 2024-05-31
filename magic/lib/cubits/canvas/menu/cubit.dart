import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/side.dart';

part 'state.dart';

class MenuCubit extends UpdatableCubit<MenuState> {
  MenuCubit() : super(const MenuState());
  @override
  String get key => 'menu';
  @override
  void reset() => emit(const MenuState());
  @override
  void setState(MenuState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);
  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void update({
    bool? active,
    bool? faded,
    Widget? child,
    Side? side,
    DifficultyMode? mode,
    SubMenu? sub,
    bool? setting,
    bool? isSubmitting,
    MenuState? prior,
  }) {
    emit(MenuState(
      active: active ?? state.active,
      faded: faded ?? state.faded,
      child: child ?? state.child,
      side: side ?? state.side,
      mode: mode ?? state.mode,
      sub: sub ?? state.sub,
      setting: setting ?? state.setting,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }

  void toggleDifficulty() {
    if (state.mode == DifficultyMode.easy) {
      update(mode: DifficultyMode.hard);
    } else {
      update(mode: DifficultyMode.easy);
    }
  }

  void toggleSetting() => update(setting: !state.setting);
  bool get isInHardMode => state.mode == DifficultyMode.hard;
  bool get isInEasyMode => state.mode == DifficultyMode.easy;
}