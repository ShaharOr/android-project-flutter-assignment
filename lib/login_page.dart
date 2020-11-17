import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/user_repository.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 18.0);
  TextEditingController _email;
  TextEditingController _password;
  TextEditingController _verifyPassword;
  final _formKey = GlobalKey<FormState>();
  final _confirmFormKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: "");
    _password = TextEditingController(text: "");
    _verifyPassword = TextEditingController(text: "");

  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Login"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        //  child: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(22),
          children: <Widget>[
            Text(
              'welcome to Startup Names Generator,\nplease log in below',
              style: TextStyle(fontSize: 18),
            ),

            TextFormField(
              controller: _email,
              validator: (value) =>
                  (value.isEmpty) ? "Please Enter Email" : null,
              style: style,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: "Email",
                  labelStyle: TextStyle(fontSize: 16.0),
                  border: UnderlineInputBorder()),
            ),

            //padding: const EdgeInsets.all(12),
            TextFormField(
              controller: _password,
              validator: (value) =>
                  (value.isEmpty) ? "Please Enter Password" : null,
              style: style,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: "Password",
                  labelStyle: TextStyle(fontSize: 16.0),
                  border: UnderlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Container(
              child: user.status == Status.Authenticating
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: <Widget>[
                        Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.red,
                          child: SizedBox(
                            width: double.infinity,
                            child: MaterialButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                if (!await user.signIn(
                                    _email.text, _password.text)) {
                                  _key.currentState.showSnackBar(SnackBar(
                                    content: Text(
                                        "There was an error logging into the app"),
                                  ));
                                } else {

                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: Text(
                              "Log In",
                              style: style.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.teal[800],
                          child: SizedBox(
                            width: double.infinity,
                            child: MaterialButton(
                            onPressed: () async {
                              showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: false,
                                  builder: (BuildContext context) {
                                    return Container(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: Form(
                                          key: _confirmFormKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                                            children: <Widget>[
                                              SizedBox(height: 20),
                                              Text(
                                                  "Please confirm your password bellow:"),
                                              TextFormField(
                                                controller: _verifyPassword,
                                                validator: (value) => value
                                                            .isEmpty ||
                                                        value == _password.text
                                                    ? null
                                                    : "Passwords must match!",
                                                style: style,
                                                decoration: InputDecoration(
                                                    prefixIcon:
                                                        Icon(Icons.lock),
                                                    labelText: "Password",
                                                    border:
                                                        UnderlineInputBorder()),
                                                obscureText: true,
                                              ),
                                              SizedBox(height: 20),
                                              ElevatedButton(
                                                  child: const Text('Confirm'),
                                                  onPressed: () async {
                                                    _confirmFormKey.currentState
                                                        .validate();
                                                    // if (_password.text != _verifyPassword.text) {
                                                    //   return ;
                                                    // }
                                                    try {

                                                      await user.signUp(
                                                          _email.text,
                                                          _password.text);

                                                      await user.signIn(
                                                          _email.text,
                                                          _password.text);

                                                    } catch (e) {
                                                      _key.currentState
                                                          .showSnackBar(
                                                              SnackBar(
                                                        content: Text(
                                                            "A server error has occurred!"),
                                                      ));
                                                      return;
                                                    }
                                                    print(
                                                        'sign up successful!');
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                  }
                                                  )
                                            ],
                                          ),
                                        ));

                                  });

                            },
                            child: Text(
                              "New user? Click to sign up",
                              style: style.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),),
                        ),
                      ],
                    ),
            ),
          ],
        ),
        //  ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
