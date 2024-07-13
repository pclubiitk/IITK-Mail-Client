import 'package:objectbox/objectbox.dart';

@Entity()
class Address {
  int id;
  String? name;
  String mailAddress;

  Address({this.id = 0, this.name, required this.mailAddress});
}
