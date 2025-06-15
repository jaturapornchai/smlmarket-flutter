import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateToHome>(_onNavigateToHome);
    on<NavigateToSearch>(_onNavigateToSearch);
    on<NavigateToProfile>(_onNavigateToProfile);
    on<NavigateToSettings>(_onNavigateToSettings);
  }

  void _onNavigateToHome(NavigateToHome event, Emitter<NavigationState> emit) {
    emit(state.copyWith(currentTab: NavigationTab.home));
  }

  void _onNavigateToSearch(
    NavigateToSearch event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(currentTab: NavigationTab.search));
  }

  void _onNavigateToProfile(
    NavigateToProfile event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(currentTab: NavigationTab.profile));
  }

  void _onNavigateToSettings(
    NavigateToSettings event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(currentTab: NavigationTab.settings));
  }
}
