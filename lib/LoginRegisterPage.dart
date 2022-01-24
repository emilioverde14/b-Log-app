import 'package:flutter/material.dart';
import 'package:flutter_blog_app/DialogBox.dart';
import 'Authentication.dart';


class LoginRegisterPage extends StatefulWidget
{
  const LoginRegisterPage
  ({
    required this.auth,
    required this.onSignedIn,
});
  final AuthImplementaion auth;
  final VoidCallback onSignedIn;


  State<StatefulWidget> createState()
  {

    return _LoginRegisterState();
  }

}




enum FormType
{
  login,
  register,
}




class _LoginRegisterState extends State<LoginRegisterPage>
{
  DialogBox dialogBox = DialogBox();

  final formKey = GlobalKey<FormState>();
  FormType _formType = FormType.login;
  var _email = "";
  var _password = "";



  bool validateAndSave()
  {
   final form = formKey.currentState;

   if(form!.validate()){
     form.save();
     return true;
   }
   else{
     return false;
   }
  }

  void validateAndSubmit() async
  {
if (validateAndSave())
  {
    try
        {
        if(_formType == FormType.login)
          {
            String userId = await widget.auth.SignIn(_email, _password);
            dialogBox.information(context, "Rieccoti in BlogApp", "Ti sei loggato correttamente");
            print("login userId = " + userId);
          }
        else
          {
            String userId = await widget.auth.SignUp(_email, _password);
            dialogBox.information(context, "Benvenuto in B-Log", "Il tuo account è stato creato correttamente.");
            print("register userId = " + userId);
          }
        widget.onSignedIn();
        }
        catch(e)
    {
      dialogBox.information(context, "Errore", e.toString());
     print("Error = " + e.toString());
    }
  }
  }



  void moveToRegister()
  {
    formKey.currentState?.reset();
    setState(()
    {
      _formType = FormType.register;
    });
   }



  void moveToLogin()
  {
    formKey.currentState?.reset();
    setState(()
    {
      _formType = FormType.login;
    });
  }




   @override
  Widget build(BuildContext context)
   {
    return Scaffold(
      backgroundColor: Colors.white,


      body: Container
        (
        margin: EdgeInsets.all(19.0),

          child: Form
     (
          key: formKey,

     child: ListView(
       //crossAxisAlignment: CrossAxisAlignment.stretch,
       children: createInputs() + createButtons(),
     )

      )

      )
    );
  }

  List<Widget> createInputs()
  {
     return
         [
           const SizedBox(height: 13.0,),
           logo(),
           const SizedBox(height: 15.0,),

           TextFormField
             (
             decoration: new InputDecoration(labelText: 'Email',hoverColor: Colors.black),


             validator: (value)
             {
               return value!.isEmpty ? 'Email is required.' : null;
             },

             onSaved: (value)
             {

               _email = value!;
             },
           ),

           const SizedBox(height: 7.0,),



           TextFormField
             (
             decoration: new InputDecoration(labelText: 'Password'),
             obscureText: true,

             validator: (value)
             {
               return value!.isEmpty ? 'Password is required.' : null;
             },

             onSaved: (value)
             {

               _password = value!;
             },
           ),

           const SizedBox(height: 20.0,),

         ];
  }

  Widget logo()
  {
    return Hero
      (
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 115.0,
        child: Image.asset('images/app_logo.png'),
      ),
    );
  }





   List<Widget> createButtons()
   {

     if(_formType == FormType.login)
     {
       return
         [
           RaisedButton
             (
             child: const Text("Login", style: TextStyle(fontSize: 20.0)),
             textColor: Colors.white,
             color: Colors.deepOrange,

             onPressed: validateAndSubmit,
           ),

           FlatButton
             (

             child: const Text("Non hai un Account? Vuoi crearne uno?", style: TextStyle(fontSize: 13.0)),
             textColor: Colors.black,

             onPressed: moveToRegister,
           )
         ];
     }

     else
       {
       return
         [
           RaisedButton
             (
             child: const Text("Crea Account", style: TextStyle(fontSize: 20.0)),
             textColor: Colors.white,
             color: Colors.deepOrange,

             onPressed: validateAndSubmit,
           ),

           FlatButton
             (
             child: const Text("Hai già un Account? Login", style: TextStyle(fontSize: 13.0)),
             textColor: Colors.black,

             onPressed: moveToLogin,

           )
         ];

     }
   }
}