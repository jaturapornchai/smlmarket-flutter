import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class NavigateToHome extends NavigationEvent {}

class NavigateToSearch extends NavigationEvent {}

class NavigateToProfile extends NavigationEvent {}

class NavigateToSettings extends NavigationEvent {}
