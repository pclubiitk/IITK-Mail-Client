import 'package:objectbox/objectbox.dart';

@Entity()
class Address {
  int id;
  String mailAddress;

  Address({this.id=0, required this.mailAddress});
}
