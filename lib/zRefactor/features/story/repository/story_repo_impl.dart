import 'package:chatoid/zRefactor/features/story/model/story.dart';
import 'package:chatoid/zRefactor/features/story/repository/story_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryRepoImpl with StoryRepo {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Story>> fetchAllStories() async {
    try {
      List<Story> allStories;
      final response =
          await supabase.from('stories').select('id, user_id, story_text');

      allStories =
          (response as List).map((story) => Story.fromJson(story)).toList();
      return allStories;
    } catch (e) {
      
    }
    return [];
  }
}
