enum MediaType {
  photo(type: "photo"),
  video(type: "video");

  const MediaType({required this.type});

  final String type;
}
