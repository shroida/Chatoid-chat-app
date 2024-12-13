import 'package:chatoid/zRefactor/core/utlis/user_data.dart';
import 'package:chatoid/zRefactor/features/profile/repository/profile_repo_impl.dart';
import 'package:chatoid/zRefactor/features/profile/view_model/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  List<UserData> friendData = [];

  final ProfileRepoImpl _profileRepoImpl = ProfileRepoImpl();
  Future<List<UserData>> fetchFriends(int userId) async {
    return  _profileRepoImpl.fetchFriends(userId);
  }
}
