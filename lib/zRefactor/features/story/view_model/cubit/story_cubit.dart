import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/zRefactor/features/story/model/story.dart';
import 'package:chatoid/zRefactor/features/story/repository/story_repo_impl.dart';
import 'package:chatoid/zRefactor/features/story/view_model/cubit/story_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryCubit extends Cubit<StoryState> {
  StoryCubit() : super(StoryInitial());
  final StoryRepoImpl _storyRepoImpl = StoryRepoImpl();

  List<Story> _allStories = [];
  List<Story> get allStories => _allStories;

  List<UserData> _allUsers = [];
  List<UserData> get allUsers => _allUsers;

  List<Map<UserData, List<Story>>> usersStory = [];
  void fetchAllStories() async {
    _allStories = await _storyRepoImpl.fetchAllStories();
    emit(StoryLoaded(_allStories));
  }
}
