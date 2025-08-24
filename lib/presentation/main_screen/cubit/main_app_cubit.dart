import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_app_state.dart'; // Regular import instead of part of

class MainAppCubit extends Cubit<MainAppState> {
  MainAppCubit() : super(MainAppState.initial());

  void changeTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }
}
