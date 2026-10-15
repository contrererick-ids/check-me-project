class Group {
  Group({
    required this.id,
    required this.name,
    required this.memberNames,
    required this.tripIds,
  });

  final String id;
  String name;
  List<String> memberNames;
  List<String> tripIds;
}