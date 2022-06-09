import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'model.dart';

class MessageDao {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref("model");
  final FirebaseStorage storage = FirebaseStorage.instance;

  void saveMessage(Model model) {
    _messagesRef.push().set(model.toJson());
    storage.ref("model").putFile(model.image);
  }

  Query getMessageQuery() {
    return _messagesRef;
  }
}
