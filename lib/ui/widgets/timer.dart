import '../../app/generalImports.dart';

class CountDownTimer {
  StreamController timerController = StreamController.broadcast();
  StreamSubscription<int>? _subscription;

  int maxTimeValue = Constant.resendOTPCountDownTime;
  //Timer? _timer;
  Stream get listenChanges => timerController.stream;

  void start(VoidCallback onEnd) {
    final Stream<int> stream = Stream.periodic(
      const Duration(seconds: 1),
      (int computationCount) {
        maxTimeValue -= 1;

        return maxTimeValue;
      },
    );
    _subscription?.cancel();

    _subscription = stream.listen((int data) {
      if (!timerController.isClosed) {
        timerController.add(data);

        if (data == 0) {
          maxTimeValue = Constant.resendOTPCountDownTime;
          onEnd();
          _subscription?.pause();
          _subscription?.cancel();
        }
      }
    });
  }

  StreamBuilder listenText({Color? color}) {
    return StreamBuilder(
      stream: timerController.stream,
      builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
        if (!snapshot.hasData) {
          return Text('-' * Constant.resendOTPCountDownTime.toString().length,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 18.0,),
              textAlign: TextAlign.center,);
        }

        return Text(snapshot.data.toString());
      },
    );
  }

  void pause() {
    _subscription?.pause();
  }

  void reset() {
    _subscription?.cancel();
    start(() {});
  }

  void resume() {
    _subscription?.resume();
  }

  void close() {
    _subscription?.cancel();
  }
}
