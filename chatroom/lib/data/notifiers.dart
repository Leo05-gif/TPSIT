import 'package:chatroom/data/constants.dart';
import 'package:flutter/cupertino.dart';

ValueNotifier<String> usernameNotifier = ValueNotifier('');
ValueNotifier<bool> isDarkNotifier = ValueNotifier(false);
ValueNotifier<TextStyle> styleTextNotifier = ValueNotifier(
  KTextStyle.defaultText,
);
