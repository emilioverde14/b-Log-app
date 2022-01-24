import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthImplementaion
{
  Future<String> SignIn(String email, String password);
  Future<String> SignUp(String email, String password);
  Future<String> getCurrentUser();
  Future<void> signOut();


}

class Auth implements AuthImplementaion {


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> SignIn(String email, String password) async
  {
    final User? user = (await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password)).user;
    return user!.uid;
  }

  Future<String> SignUp(String email, String password) async
  {
    User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password)).user;
    return user!.uid;
  }

  Future<String> getCurrentUser() async
  {
    User? user = _firebaseAuth.currentUser;
    return user!.uid;
  }


  Future<void> signOut() async
  {
    _firebaseAuth.signOut();
  }



}




