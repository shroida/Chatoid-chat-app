import 'package:chatoid/features/story/model/story.dart';

sealed class StoryState {}

final class StoryInitial extends StoryState {}

final class StoryLoading extends StoryState {}

final class StoryError extends StoryState {
  StoryError(String errorMsg);
}

final class StoryLoaded extends StoryState {
  StoryLoaded(List<Story> allStories);
}