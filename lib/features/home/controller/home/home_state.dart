part of 'home_notifier.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
  }) = _HomeState;

  factory HomeState.initial() => const HomeState();
}
