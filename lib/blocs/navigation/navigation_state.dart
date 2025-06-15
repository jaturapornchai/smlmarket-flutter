import 'package:equatable/equatable.dart';

enum NavigationTab { home, search, profile, settings }

class NavigationState extends Equatable {
  final NavigationTab currentTab;

  const NavigationState({this.currentTab = NavigationTab.home});

  @override
  List<Object?> get props => [currentTab];

  NavigationState copyWith({NavigationTab? currentTab}) {
    return NavigationState(currentTab: currentTab ?? this.currentTab);
  }
}
