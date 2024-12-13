class Story {
  final int id;
  final int userId;
  final String storyText; // Example field

  Story({
    required this.id,
    required this.userId,
    required this.storyText,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['user_id'],
      storyText: json['story_text'],
    );
  }

  @override
  String toString() {
    return 'Story(id: $id, userId: $userId, storyText: $storyText, ';
  }
}
