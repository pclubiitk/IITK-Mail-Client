import "objectbox.dart" ;

late ObjectBox objectbox ;

Future<void> initializeObjectBox() async{
  objectbox = await ObjectBox.create() ;
}