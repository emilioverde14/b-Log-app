import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



class UploadPhotoPage extends StatefulWidget
{
  State<StatefulWidget> createState()
  {
    return _UploadPhotoPageState();
  }
}

class _UploadPhotoPageState extends State<UploadPhotoPage>
{

  var sampleImage;
  var tempImage;
  late String url;
  late String _myValue;
  final formKey = GlobalKey<FormState>();




  Future getImage() async
  {
    ImagePicker _picker = ImagePicker();
    tempImage = (await _picker.pickImage(source: ImageSource.gallery))!;

    setState(() {
      sampleImage = tempImage;
    });

  }


  bool validateAndSave()
  {
    final form = formKey.currentState;

    if(form!.validate())
      {
        form.save();
        return true;
      }
    else{
      return false;
    }
  }



  void uploadStatusImage() async
  {
    if(validateAndSave())
      {


        final Reference postImageRef = FirebaseStorage.instance.ref().child("Post Images"); // creo un istanza nel database storage creando un ramo "immagini postate"

        var timeKey = DateTime.now(); // salvo nella variaile timekey il dateTime attuale

        final Task uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(File(sampleImage.path));// faccio il put dell'immagine nello storage con il timekey + .jpg

        String ImageUrl = await (await uploadTask).ref.getDownloadURL();  //ricavo l'url dell immagine caricata

        url = ImageUrl.toString(); // converto in stringa

        print("Url immagine caricata= " + url); // stampo nel terminale

        saveToDatabase(url); // richiamo il metodo saveToDatabase passando "url" come parametro
        goToHomePage();// richiamo il metodo per ritornare in Home dopo il salvataggio nel database
      }
  }


  void saveToDatabase(url) // salvataggio nel database di data, descrizione, url, orario
  {
    var dbTimeKey = DateTime.now();// salvo in dbTimeKey l'ora attuale
    var formatDate = DateFormat('MMM d, yyyy');// formato data
    var formatTime = DateFormat('EEEE, hh:mm aaa'); // formato ora

    String date = formatDate.format(dbTimeKey);// creo la stringa data
    String time = formatTime.format(dbTimeKey);// creo la stringa orario

    DatabaseReference ref = FirebaseDatabase.instance.reference();// creo una referenza nel database chiamandola ref

    var data = // questi sono i parametri che voglio salvare nel database
    {
      "url": url,
      "descrizione": _myValue,
      "data": date,
      "ora": time
    };

    ref.child("Posts").push().set(data);// tramite l'istanza ref creo un ramo "posts" nel database e faccio una push dei dati che voglio inserire (set(data))


  }

  void goToHomePage()   // ritorna alla homepage una volta che è stato caricato il file sul database
  {
  Navigator.pop(context);
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold
      (
      appBar: AppBar
        (
       title: const Text("Carica immagine"),
        centerTitle: true,
      ),

      body: Center
        (
        child: sampleImage == null? const Text("Seleziona un'immagine"): enableUpload(),
      ),

      floatingActionButton: FloatingActionButton
        (

        tooltip: 'AGGIUNGI IMMAGINE',
        child: const Icon(Icons.add_a_photo),
        onPressed: getImage,

      ),

    );
  }





  Widget enableUpload()
  {
  return Container
    (

    child: Form
      (
      key: formKey,

      child: ListView
        (
        children: <Widget>
        [
          const SizedBox(height: 20.0,),
          Image.file(File(sampleImage.path), height: 250.0,width: 660,),

          const SizedBox(height: 13.0,),

          TextFormField
            (
            decoration: const InputDecoration(labelText: 'Descrizione'),

            validator: (value)
            {
              return value!.isEmpty ? 'Descrizione mancante' : null;
            },

            onSaved: (value)
            {
              _myValue = value!; // inserisce ciò che è stato scritto nel box descrizione in _myValue
            },
          ),

          SizedBox(height: 5.0,),

          RaisedButton
            (

            elevation: 10.0,
            child: const Text("Aggiungi post"),
            textColor: Colors.white ,
            color: Colors.deepOrange,


            onPressed: uploadStatusImage,

          )

        ],

      ),
    ),

    );
  }
}