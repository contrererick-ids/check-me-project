import 'package:proyecto_entrega1/models/group.dart';

final List<Map<String, String>> amigosGrupoDummy = [
  {'nombre': 'Jazmin', 'celular': '+52 33 64 89 25 45'},
  {'nombre': 'José', 'celular': '+52 33 97 56 24 58'},
  {'nombre': 'Raúl', 'celular': '+52 33 66 99 77 55'},
  {'nombre': 'Milena', 'celular': '+52 33 99 88 55 44'},
  {'nombre': 'Luis', 'celular': '+52 33 55 88 11 74'},
];

var groups = [
  Group(
    id: "group1",
    name: "Amigos de la universidad",
    memberNames: ["Jazmin", "José", "Raúl", "Milena", "Luis"],
    tripIds: ["trip1", "trip2"],
  ),
  Group(
    id: "group2",
    name: "Compañeros de trabajo",
    memberNames: ["Jazmin", "Luis"],
    tripIds: [],
  ),
];
