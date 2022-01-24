import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Posts.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  _FavoriteState createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {

  List<Posts> postsList = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();

    FavoriteFunc();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preferiti",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: Colors.deepOrange,),
      body: Container
        (

        child: postsList.isEmpty ? const Text("  Non hai post nei preferiti",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),) : ListView.builder
          (
            itemCount: postsList.length,
            itemBuilder: (_, index)
            {
              return PostsUI(postsList[index].url, postsList[index].descrizione ,postsList[index].data ,postsList[index].ora,postsList[index].uploadid,index);
            }

        ),

      ),
    );
  }

  Widget PostsUI(String url, String descrizione, String data, String ora, String uploadId, int index)
  {
    return Card
      (
      
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
    ),
    shadowColor: Colors.black87,
    elevation: 11.0,
    margin: const EdgeInsets.all(16.0),


      child: Container
        (
        padding: const EdgeInsets.all(15.0),

        child: Column
          (
          crossAxisAlignment: CrossAxisAlignment.end,

          children: <Widget>
          [
            Row
              (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>
              [

                Text
                  (
                  data,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),

                Text
                  (
                  ora,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                )
              ],
            ),


            const SizedBox(height: 10.0,),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(url, fit: BoxFit.cover),
            ),

            const SizedBox(height: 10.0,),

            Row
              (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>
              [
                Flexible(
                  child: Text
                    (
                    descrizione,
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.left,
                  ),

                )
              ],
            ),



            IconButton(icon: Icon(Icons.delete_sweep,color: Colors.deepOrange,), onPressed: (){
              User? currentUser = FirebaseAuth.instance.currentUser;
              if(currentUser == null) {
                null;
              }
              else {
                DatabaseReference favRef = FirebaseDatabase.instance.reference().child("Posts").child(uploadId).child("Fav")
                    .child(currentUser.uid).child("state");
                favRef.set("false");
                setState(() {
                  FavoriteFunc();
                });
              }

            }),


          ],
        ),
      ),
    );
  }

  void FavoriteFunc() {

    DatabaseReference postsRef = FirebaseDatabase.instance.reference().child(
        "Posts");

    postsRef.once().then((snap) {
      var map = Map<String, dynamic>.from(
          snap.snapshot.value as Map<dynamic, dynamic>);

      postsList.clear();



      map.forEach((key, value) {
        var values = Map<String, dynamic>.from(map);
        Posts posts = Posts
          (
            values[key]['url'],
            values[key]['descrizione'],
            values[key]['data'],
            values[key]['ora'],
            key
        );

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          null;
        }
        else {
          DatabaseReference reference = FirebaseDatabase.instance.reference()
              .child("Posts").child(key).child("Fav")
              .child(currentUser.uid)
              .child("state");
          reference.once().then((snapShot) {
            if (snapShot.snapshot.value != null) {
              if(snapShot.snapshot.value=="true"){
                postsList.add(posts);
              }
            }
          });
        }
      });


      Timer(Duration(seconds: 1), () {
        setState(() {
          //
        });
      });
    });

  }
}
