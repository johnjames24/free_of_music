part of k;

void main() {
  runApp(Root());
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: MusicPlayer(),
      ),
    );
  }
}
