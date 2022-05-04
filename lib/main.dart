import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(body: SampleWidget()),
    );
  }
}

final openSite = BehaviorSubject<bool>();


class SampleWidget extends ConsumerWidget {
  const SampleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      ref.watch(streamProvider).when(data: (anyData) {
        print("ok");
      }, error: (error, stacktrace) {
        print("It's error. Stacktrace: " + stacktrace.toString());
      }, loading: () {});
    } on LaunchUrlException catch (error) {
      print("It's error. Stacktrace: " + error.toString());
    }
    return Container();
  }
}

final baseProvider = Provider((ref) {
  final Stream<AsyncValue<void>> launchStream = sampleStream.map((event) {
    if (event.value == null) {
      return const AsyncValue<void>.data(null);
    } else {
      openSite.addStream(launchUrlString(event.value!).asStream());
    }
    return const AsyncValue<void>.data(null);
  });
  return launchStream;
});

final streamProvider = StreamProvider((ref) {
  openSite.stream.listen((isOpenSite) {
    if (!isOpenSite) {
      throw LaunchUrlException();
    }
  });
  return ref.watch(baseProvider);
});

late final Stream<AsyncValue<String>> sampleStream = Stream.value(null).map((_) {
  return const AsyncValue.data('https://google.com');
});

class LaunchUrlException implements Exception {}


