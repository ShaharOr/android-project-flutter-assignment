import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/login_page.dart';
import 'package:hello_me/user_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'dart:io';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserRepository>(
      create: (context) => UserRepository.instance(),
      child: Consumer<UserRepository>(
          builder: (context, UserRepository user, child) {
        return MaterialApp(
          title: 'Startup Name Generator',
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
          home: RandomWords(),
        );
      }),
    );
  }
}

class RandomWords extends StatefulWidget {
  //  final UserRepository user;
  const RandomWords(); //this.user

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  final _profileSheetcontroller = SnappingSheetController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: [
            IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
            IconButton(
                icon: Provider.of<UserRepository>(context).status ==
                        Status.Authenticated
                    ? Icon(Icons.exit_to_app)
                    : Icon(Icons.login),
                onPressed: Provider.of<UserRepository>(context).status ==
                        Status.Authenticated
                    ? signOut
                    : _pushLogin),
          ],
        ),
        //body: _buildSuggestions(),
        body:
            Provider.of<UserRepository>(context).status == Status.Authenticated
                ? _profileSnappingSheet()
                : _buildSuggestions());
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }

          return _buildRow(_suggestions[index]);
        });
  }

  Widget _profileSnappingSheet() {
    return SnappingSheet(
      snappingSheetController: _profileSheetcontroller,
      child: _buildSuggestions(),
      snapPositions: [
        SnapPosition(
            positionFactor: 0.0,
            snappingCurve: Curves.elasticInOut,
            snappingDuration: Duration(milliseconds: 650)),
        SnapPosition(
            positionFactor: 0.35,
            snappingCurve: Curves.elasticInOut,
            snappingDuration: Duration(milliseconds: 500)),
      ],
      sheetBelow: SnappingSheetContent(
          child: Container(
            padding: EdgeInsets.all(22),
            color: Colors.white,
            child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
                leading:
                Provider.of<UserRepository>(context).imageUrl == null
                    ? SizedBox(
                    width: 60.0,
                    height: 60.0,
                    child: Center(child: Icon(Icons.assignment_ind_outlined,size: 30,)))
                    : CircleAvatar(
                       backgroundImage: NetworkImage(Provider.of<UserRepository>(context).imageUrl,),
                  radius: 30,

                ),

                title: Text('${  Provider.of<UserRepository>(context).user.email}', style: TextStyle(fontSize: 20.0)),
                subtitle: Container(
                  height: 30,
                  margin: const EdgeInsets.only(top: 10.0),
                  child: RaisedButton(
                    onPressed: () async {
                      // Pick an image with the file_picker library
                      FilePickerResult result = await FilePicker.platform
                          .pickFiles(type: FileType.image);

                      if (result != null) {
                        File file = File(result.files.single.path);
                        setState(() {
                          Provider.of<UserRepository>(context,listen: false).imageUrl = null;
                        });
                        Provider.of<UserRepository>(context,listen: false).imageUrl = await Provider.of<UserRepository>(context,listen: false).uploadImage(file,  Provider.of<UserRepository>(context,listen: false).user.uid + ".png");
                        setState(() {});
                      }
                    },
                    child: Text("change avatar"),
                    color: Colors.teal,
                    textColor: Colors.white,
                  ),
                )
            ),
          ),
          heightBehavior: SnappingSheetHeight.fit()),
      grabbing: Container(
        color: Colors.grey[300],
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
          child: InkWell(
            onTap:(){
              if (_profileSheetcontroller.snapPositions.last !=
                      _profileSheetcontroller.currentSnapPosition) {
                    _profileSheetcontroller.snapToPosition(
                        _profileSheetcontroller.snapPositions.last);
                  } else {
                    _profileSheetcontroller.snapToPosition(
                        _profileSheetcontroller.snapPositions.first);
                  }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'welcome back, ${Provider.of<UserRepository>(context)?.user?.email}',
                  style: TextStyle(fontSize: 14),
                ),
                Icon(Icons.keyboard_arrow_up)

              ],
            ),
          ),
        ),
      ),
     grabbingHeight: MediaQuery.of(context).padding.bottom + 60,
    );
  }

  void signOut() {
    Provider.of<UserRepository>(context, listen: false).signOut();
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          var user = Provider.of<UserRepository>(context);
          final tiles = user.localSaved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
                trailing: Builder(
                  //these 2 lines
                  builder: (context) => IconButton(
                    //solve the problem
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      user.removeWordFromSaved(pair);
                    },
                  ),
                ),
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: tiles,
              ).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(WordPair pair) {
    var user = Provider.of<UserRepository>(context);
    final alreadySaved = user.localSaved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            user.removeWordFromSaved(pair);
            //_saved.remove(pair);
          } else {
            user.addWordToSaved(pair);
          }
        });
      },
    );
  }

  void _pushLogin() {
    Navigator.of(context).push(
      // LoginPage()
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return LoginPage();
        },
      ),
    );
  }
}
