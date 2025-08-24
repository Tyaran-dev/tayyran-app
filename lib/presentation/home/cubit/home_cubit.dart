// home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState.initial());

  void changeTab(String tab) {
    emit(state.copyWith(selectedTab: tab));
  }
}
