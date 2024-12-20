// ignore_for_file: public_member_api_docs, sort_constructors_first
class ClsPost {
  String postsText;
  int id;
  DateTime createdAt;
  int reacts;
  ClsPost({
    required this.postsText,
    required this.id,
    required this.createdAt,
    required this.reacts,
  });
  Map<String, dynamic> toJson() => {
        'post_text': postsText,
        'user_id': id,
        'created_at': createdAt,
        'reacts': reacts
      };
  factory ClsPost.fromJson(Map<String, dynamic> json) {
    return ClsPost(
        postsText: json['post_text'],
        id: json['user_id'],
        createdAt: json['created_at'],
        reacts: json['reacts']);
  }
}
