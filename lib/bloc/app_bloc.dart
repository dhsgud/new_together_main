import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial());

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    }
  }

  Stream<AppState> _mapAppStartedToState() async* {
    yield AppLoading();
    try {
      // Firebase 초기화와 같은 비동기 작업 수행
      await Future.delayed(Duration(seconds: 2));
      yield AppLoaded();
    } catch (e) {
      yield AppError(message: e.toString());
    }
  }
}
