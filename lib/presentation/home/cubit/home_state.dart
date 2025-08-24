// home_state.dart
import 'package:flutter/foundation.dart';

@immutable
class HomeState {
  final String selectedTab;

  const HomeState({this.selectedTab = "flight"});

  HomeState copyWith({String? selectedTab}) {
    return HomeState(selectedTab: selectedTab ?? this.selectedTab);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeState && other.selectedTab == selectedTab;
  }

  @override
  int get hashCode => selectedTab.hashCode;

  static HomeState initial() {
    return const HomeState();
  }
}
