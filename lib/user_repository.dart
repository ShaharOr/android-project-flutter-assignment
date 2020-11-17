import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;

  Status _status = Status.Uninitialized;
  final _firestore = FirebaseFirestore.instance;
  final  FirebaseStorage _storage = FirebaseStorage.instance;
  final _localSaved = Set<WordPair>();
  String imageUrl;


  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    _localSaved.clear();
    notifyListeners();

  }


  Status get status => _status;
  User get user => _user;
  Set<WordPair> get localSaved =>_localSaved;

  Future<String> uploadImage(File file, String name) {
    return _storage
        .ref('images')
        .child(name)
        .putFile(file)
        .then((snapshot) => snapshot.ref.getDownloadURL());
  }

  Future<String> getImageUrl(String name) {
    return _storage.ref('images').child(name).getDownloadURL();
  }


  Future<bool> signIn(String email, String password) async {
    _status = Status.Authenticating;
    notifyListeners();

    try {
      await getImageUrl(_user.uid + ".png").then((value) => imageUrl = value);
    }
    catch(e){
      imageUrl = null;
    }
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _status = Status.Authenticated;
      await mergeLocalSavedWithCloud();
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;

      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    _localSaved.clear();
    imageUrl = null;
    notifyListeners();

    return Future.delayed(Duration.zero);
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      var ret_val = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await addUserToFirestore(email);
      return ret_val;
    } catch (e) {
      print(e);

      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<String> getDocIdByEmail(String email) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
    } else {
        return null;
    }

  }

  Future<bool> addUserToFirestore(String email) async {
    bool return_val=true;
    await _firestore
        .collection('users')
        .doc(_user.uid).set({
      'email': email,
      "saved": wordPairSetToStringList(localSaved),
      'created_at': Timestamp.now()})
        .then((value) => print("User Added"))
        .catchError((error){ return_val=false; print("Failed to add user: $error");});
    return return_val;
  }


  Future<bool> removeWordFromSaved(WordPair word) async{
      _localSaved.remove(word);
      if (_status == Status.Authenticated){
        await updateSavedOnCloud(_localSaved);
      }
      notifyListeners();
  }
  Future<bool> addWordToSaved(WordPair word) async{
    _localSaved.add(word);
    if (_status == Status.Authenticated){
      await updateSavedOnCloud(_localSaved);
    }
    notifyListeners();
  }
  Future<bool> mergeLocalSavedWithCloud() async{
    Set<WordPair> cloudSaved= await getCloudSaved();
    _localSaved.addAll(cloudSaved);
    if (_status == Status.Authenticated){
      await updateSavedOnCloud(_localSaved);
    }
    notifyListeners();
  }
  Future<Set<WordPair>> getCloudSaved() async {
    final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
    var snapshot = await _firestore.collection('users').doc(_user.uid).get();
    var recived_set=snapshot["saved"].toSet();
    Set<WordPair> returnSet=Set<WordPair>();
    for (String str in recived_set){
      var pair=str.split(beforeCapitalLetter);
      if (pair.isNotEmpty && pair[0].isNotEmpty && pair[1].isNotEmpty)
        returnSet.add(WordPair(pair[0], pair[1]));
    }
    return returnSet;
  }


  Future<bool>updateSavedOnCloud(Set<WordPair> currentSaved)async{
    if (_status == Status.Authenticated){
      _firestore.collection("users").doc(_user.uid).update({
        "saved":  wordPairSetToStringList(currentSaved)
      }).then((_){return true;});

    }
  }
  List<String> wordPairSetToStringList(Set<WordPair> set){
    var list=List<String>();
    for (var w in set ){
      list.add(w.asPascalCase);
    }
    return list;
  }
}
