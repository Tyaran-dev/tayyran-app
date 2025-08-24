import 'package:flutter/foundation.dart';

@immutable
class MainAppState {
  final int currentTabIndex;

  const MainAppState({this.currentTabIndex = 0});

  MainAppState copyWith({int? currentTabIndex}) {
    return MainAppState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MainAppState && other.currentTabIndex == currentTabIndex;
  }

  @override
  int get hashCode => currentTabIndex.hashCode;

  static MainAppState initial() {
    return const MainAppState();
  }
}
