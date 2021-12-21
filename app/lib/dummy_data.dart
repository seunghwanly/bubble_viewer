import 'package:app/floating_chat.dart';

FloatingChat dummyCenter = FloatingChat(
    name: "center",
    distance: 0.0,
    radius: 35.0,
    hasUpdate: true,
    top: 0,
    left: 0);

List<FloatingChat> dummyChats = [
  FloatingChat(
      name: "test1",
      distance: 7.0,
      radius: 35.0,
      hasUpdate: false,
      top: 0,
      left: 0),
  FloatingChat(
      name: "test2",
      distance: 16.0,
      radius: 43.0,
      hasUpdate: true,
      top: 0.0,
      left: 0.0),
  FloatingChat(
      name: "test3",
      distance: 8.0,
      radius: 27.0,
      hasUpdate: false,
      top: 0.0,
      left: 0.0),
  FloatingChat(
      name: "test4",
      distance: 54.0,
      radius: 18.0,
      hasUpdate: true,
      top: 0.0,
      left: 0.0),
];
