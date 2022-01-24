import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_app/PhotoUpload.dart';
import 'Authentication.dart';
import 'PhotoUpload.dart';
import 'Posts.dart';
import 'dart:core';
import 'package:flutter_blog_app/Favorite.dart';



class HomePage extends StatefulWidget {

  HomePage
  (
      {
    required this.auth,
    required this.onSignedOut,
}
);

 AuthImplementaion auth;
 VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState()
  {
    return _HomePageState();
  }

}


class _HomePageState extends State<HomePage> {

  List<Posts> postsList = [];
  List<bool> favList = [];
  FirebaseAuth auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();


    DatabaseReference postsRef = FirebaseDatabase.instance.reference().child(
        "Posts");

    postsRef.once().then((snap) {
      var map = Map<String, dynamic>.from(
          snap.snapshot.value as Map<dynamic, dynamic>);

      postsList.clear();
      favList.clear();


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

        postsList.add(posts);
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
              if (snapShot.snapshot.value == "true") {
                favList.add(true);
              } else {
                favList.add(false);
              }
            } else {
              favList.add(false);
            }
          });
        }
      });


      Timer(Duration(seconds: 1), () {
        setState(() {
          print('Length : $postsList.length');
        });
      });
    });
  }



  void _logoutUser() async
  {
   try
       {
      await widget.auth.signOut();
      widget.onSignedOut();
       }
       catch(e)
    {
      print(e.toString());
    }
  }




  @override
  Widget build(BuildContext context)
  {
  return Scaffold
    (
    backgroundColor: Colors.white,
      drawerScrimColor: Colors.black,
    appBar: AppBar
      (
      title: const Text("Home"),
      ),

    body:  Container
      (

        child: postsList.isEmpty ? const Text("Non ci sono articoli da visualizzare") : ListView.builder
        (
        itemCount: postsList.length,
        itemBuilder: (_, index)
          {
            return PostsUI(postsList[index].url, postsList[index].descrizione ,postsList[index].data ,postsList[index].ora,postsList[index].uploadid,index);
          }

      ),

      ),

    bottomNavigationBar: BottomAppBar
      (
      color: Colors.deepOrange,

      child: Container
        (

         margin: const EdgeInsets.only(left: 70.0, right: 70.0),

        child: Row
          (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,

          children: <Widget>
          [


            IconButton
              (
              icon: const Icon(Icons.favorite),
              iconSize: 40,
              color: Colors.white,
              onPressed: ()
              {
                Navigator.push
                  (
                    context,
                    MaterialPageRoute(builder: (context)
                    {
                      return Favorite();
                    })
                );
              },
            ),

            IconButton
              (
              icon: const Icon(Icons.add_a_photo),
              iconSize: 40,
              color: Colors.white,

              onPressed: ()
              {
                Navigator.push
                  (
                    context,
                    MaterialPageRoute(builder: (context)
                    {
                      return UploadPhotoPage();
                    })
                );
              },
            ),


            IconButton
              (
              icon: const Icon(Icons.logout),
              iconSize: 40,
              color: Colors.white,
              onPressed: _logoutUser,
            ),



          ],

        ),

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

         padding: const EdgeInsets.all(19.0),

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


             const SizedBox(height: 20.0,),

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


             favList[index]?
             IconButton(icon: Icon(Icons.favorite,color: Colors.deepOrange,), onPressed: (){
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

             }):


             IconButton(icon: Icon(Icons.favorite_border,color: Colors.deepOrange,), onPressed: (){
             User? currentUser = FirebaseAuth.instance.currentUser;
              if(currentUser == null) {
               null;}
               else {
                DatabaseReference favRef = FirebaseDatabase.instance.reference()
                    .child("Posts").child(uploadId).child("Fav")
                    .child(currentUser.uid)
                    .child("state");
                favRef.set("true");
                setState(() {
                  FavoriteFunc();
                });
              }

               })




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

       favList.clear();


       map.forEach((key, value) {
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
               if (snapShot.snapshot.value == "true") {
                 favList.add(true);
               } else {
                 favList.add(false);
               }
             } else {
               favList.add(false);
             }
           });
         }

         Timer(Duration(seconds: 1), () {
           setState(() {
             //
           });
         });


       });
     });
   }
} // FINE CLASS _HOMEPAGESTATE




