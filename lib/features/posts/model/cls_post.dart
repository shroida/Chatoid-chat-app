// ignore_for_file: public_member_api_docs, sort_constructors_first
class ClsPost {
  String postsText;
  int postID;
  int userID;
  DateTime createdAt;
  int reacts;
  ClsPost({
    required this.postsText,
    required this.userID,
    required this.postID,
    required this.createdAt,
    required this.reacts,
  });
  Map<String, dynamic> toJson() => {
        'post_text': postsText,
        'user_id': userID,
        'id': postID,
        'created_at': createdAt,
        'reacts': reacts
      };
  factory ClsPost.fromJson(Map<String, dynamic> json) {
    return ClsPost(
        postsText: json['post_text'],
        userID: json['user_id'],
        postID: json['id'],
        createdAt: json['created_at'],
        reacts: json['reacts']);
  }
  // Add the copyWith method
  ClsPost copyWith({
    String? postsText,
    int? postID,
    int? userID,
    DateTime? createdAt,
    int? reacts,
  }) {
    return ClsPost(
      postsText: postsText ?? this.postsText,
      postID: postID ?? this.postID,
      userID: userID ?? this.userID,
      createdAt: createdAt ?? this.createdAt,
      reacts: reacts ?? this.reacts,
    );
  }
}
