import 'package:flutter/material.dart';
import 'package:flutter_blog_app/LoginRegisterPage.dart';
import 'package:flutter_blog_app/HomePage.dart';
import 'package:flutter_blog_app/Authentication.dart';

class MappingPage extends StatefulWidget
{
  final AuthImplementaion auth;

  MappingPage
      ({
   required this.auth,
});

State<StatefulWidget> createState()
{
  return _MappingPageState();
}

}


enum AuthStatus
{
  notSignedId,
  signedIn,
}




class _MappingPageState extends State<MappingPage>
{
   AuthStatus authStatus = AuthStatus.notSignedId;


  @override
  void initState()
  {
    super.initState();

    widget.auth.getCurrentUser().then((firebaseUserId)
        {
         setState(() {
           authStatus = firebaseUserId == null ? AuthStatus.notSignedId : AuthStatus.signedIn;
         });
        });
  }


  void _signedIn()
  {

    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }


   void _signOut()
   {

     setState(() {
       authStatus = AuthStatus.notSignedId;
     });
   }






@override
  Widget build(BuildContext context)
{

  switch(authStatus)
  {
    case AuthStatus.notSignedId:
      return LoginRegisterPage
        (
        auth: widget.auth,
        onSignedIn: _signedIn,
      );

    case AuthStatus.signedIn:
      return HomePage
        (
        auth: widget.auth,
        onSignedOut: _signOut,
      );
  }

  }
}
