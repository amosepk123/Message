import 'package:flutter/cupertino.dart';

class NameProvider extends ChangeNotifier{
  late String name;
  NameProvider({ this.name='N/A'});

  void changeName({
    required String newName
  }) async{
    name=newName;
    notifyListeners();
  }
}