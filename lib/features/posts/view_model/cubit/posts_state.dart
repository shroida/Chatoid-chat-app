import 'package:chatoid/features/posts/model/cls_post.dart';

sealed class PostsState {}

final class PostsInitial extends PostsState {}

final class PostsLoading extends PostsState {}

final class PostsLoaded extends PostsState {
  final List<ClsPost> posts;

  PostsLoaded({required this.posts});
}

final class PostsError extends PostsState {
  final String errorMsg;

  PostsError({required this.errorMsg});
}
