part of k.ui_layer;

///Mounts all the UI
class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        iconTheme: ThemeData.dark().iconTheme.copyWith(
              color: ThemeData.dark().iconTheme.color.withAlpha(180),
            ),
      ),
      // theme: ThemeData().copyWith(
      //   iconTheme: ThemeData().iconTheme.copyWith(
      //         color: ThemeData().iconTheme.color.withAlpha(180),
      //       ),
      // ),
      home: Structure(
          child: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              //https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M?si=F32qM0qpTLGV2nVRiVhT1A
              InheritedMusicplayer.of(context)
                  .initfromPlaylist("37i9dQZF1DWZeKCadgRdKQ");
            },
            child: Text("start"),
          ),
          RaisedButton(
            onPressed: () {
              InheritedMusicplayer.of(context).stop();
            },
            child: Text("stop"),
          ),
          RaisedButton(
            onPressed: clearYtbCache,
            child: Text("clear cache"),
          ),
        ],
      )),
    );
  }
}

clearYtbCache() async {
  await BasicDataStorageManager.init();
  var yt = YoutubeDataManager();
  await yt.init();
  await yt.dropCache();
  await yt.cleanUp();
}
