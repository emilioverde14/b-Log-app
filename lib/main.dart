import 'package:flutter/material.dart';
import 'package:flutter_blog_app/Mapping.dart';
import 'package:flutter_blog_app/Authentication.dart';
import 'package:firebase_core/firebase_core.dart';



Future<void> main ()
async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BlogApp());

}



class BlogApp extends StatelessWidget
{
  const BlogApp({Key? key}) : super(key: key);

@override
  Widget build(BuildContext context)
{
    return MaterialApp
      (

      title: "B-log",
      theme: ThemeData
        (
        primarySwatch: Colors.deepOrange,
      ),
      home: MappingPage(auth: Auth(),),
    );
  }
}