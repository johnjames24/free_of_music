part of k;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BasicDataStorageManager.init();
  runApp(SamplePlayer());
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DataStorageTesting.testRead();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          sliderTheme: SliderThemeData().copyWith(
        activeTrackColor: Color.fromRGBO(140, 130, 122, 1),
        thumbColor: Color.fromRGBO(140, 130, 122, 1),
        inactiveTrackColor: Color.fromRGBO(140, 130, 122, 0.44),
      )),
      home: Scaffold(
        body: Text("Hello World!"),
      ),
    );
  }
}
