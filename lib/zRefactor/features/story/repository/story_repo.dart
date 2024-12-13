import 'package:chatoid/zRefactor/features/story/model/story.dart';

mixin StoryRepo {
  Future<List<Story>> fetchAllStories();
}
