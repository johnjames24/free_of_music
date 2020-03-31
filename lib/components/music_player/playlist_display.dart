part of k;

class PlaylistPg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var imgUrl =
        "https://images.genius.com/9eaffc86180a5a1afa80243553b8dd5c.1000x1000x1.jpg";
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(0),
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              height: 250,
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => print("go back"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          child: ClipRect(
                            child: Container(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Card(
                                  elevation: 10,
                                  child: Image.network(imgUrl),
                                ),
                                heightFactor: 1,
                                widthFactor: 1,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Adventure of Lifetime",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Coldplay",
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    TabBar(
                      tabs: <Widget>[
                        Tab(
                          child: Text("queue"),
                        ),
                        Tab(
                          child: Text("history"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: TabBarView(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                ],
              ),
              ListView(
                children: <Widget>[
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Animal Control"),
                    subtitle: Text("Billie Elish"),
                    leading: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => print("like"),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.drag_handle),
                      onPressed: () => print("like"),
                    ),
                  ),
                  Divider(),
                ],
              ),
            ],
          )),
          Card(
            margin: EdgeInsets.all(0),
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              height: 100,
            ),
          )
        ],
      ),
    );
  }
}
