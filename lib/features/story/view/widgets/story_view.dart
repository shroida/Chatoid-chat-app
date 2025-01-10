import 'package:chatoid/constants.dart';
import 'package:chatoid/core/utlis/app_router.dart';
import 'package:chatoid/features/story/model/story.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/messages/view/widgets/my_header_widget.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/story/view/widgets/eye_views.dart';
import 'package:chatoid/features/story/view_model/cubit/story_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StoryView extends StatefulWidget {
  final List<Story> stories;
  final String username;
  final int initialIndex;
  final bool isCurrentUserStory;

  const StoryView({
    super.key,
    required this.stories,
    required this.username,
    required this.isCurrentUserStory,
    this.initialIndex = 0,
  });

  @override
  StoryViewState createState() => StoryViewState();
}

class StoryViewState extends State<StoryView> {
  late PageController _pageController;
  late int _currentIndex;
  List<Map<UserData, List<Story>>> _viewers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;

    // Update current index when page changes
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.round();
      });
    });
    _getViewers(widget.stories[0].id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getViewers(int storyId) async {
    final storyCubit = Provider.of<StoryCubit>(context, listen: false);
    final loginCubit = Provider.of<LoginCubit>(context, listen: false);

    try {
      // Clear the previous viewers before fetching new ones
      setState(() {
        _viewers.clear();
      });

      // Fetch viewers for the specific story
      List<Map<UserData, List<Story>>> viewers =
          await storyCubit.retrieveViewersForMyStories(
        loginCubit.currentUser.userId,
        storyId,
      );
      setState(() {
        _viewers = viewers; // Update the state with fetched viewers
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginCubit = context.read<LoginCubit>();

    return Scaffold(
      backgroundColor: ChatAppColors.appBarColor,
      body: Column(
        children: [
          MyHeaderWidget(
            userProfile: loginCubit.currentUser,
            headername: widget.username,
            leftIcon: Icons.abc,
            backgroundColor: ChatAppColors.appBarColor,
          ),
          const SizedBox(height: 20),
          SmoothPageIndicator(
            controller: _pageController,
            count: widget.stories.length,
            effect: WormEffect(
              activeDotColor: Colors.blue,
              dotColor: Colors.white.withOpacity(0.5),
              dotHeight: 10,
              dotWidth: 100,
              spacing: 8.0,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double fontSize = constraints.maxWidth / 15;

                        return Text(
                          widget.stories[index].storyText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize.clamp(
                                6.0, 24.0), // Minimum and maximum size
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 15, // Limit the number of lines
                          overflow: TextOverflow
                              .ellipsis, // Show ellipsis if overflow
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (widget.isCurrentUserStory)
            GestureDetector(
              onTap: () async {
                // Fetch viewers for the current story based on _currentIndex
                await _getViewers(widget.stories[_currentIndex].id);
                if (context.mounted) {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        height: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                // Call the deleteStory method when the button is pressed
                                final storyCubit = Provider.of<StoryCubit>(
                                    context,
                                    listen:
                                        false); // Get an instance of your storyCubit
                                await storyCubit.deleteStory(
                                    widget.stories[_currentIndex].id);
                                if (context.mounted) {
                                  GoRouter.of(context)
                                      .push(AppRouter.kHomePage);
                                }
                                setState(() {});
                              },
                              child: const Icon(Icons.delete,
                                  color: ChatAppColors.primaryColor4),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _viewers.length,
                                itemBuilder: (context, index) {
                                  // Extract the UserData key from the map
                                  UserData userData =
                                      _viewers[index].keys.first;

                                  return ListTile(
                                    leading: const CircleAvatar(
                                      backgroundImage: AssetImage(
                                          'assets/profile.gif'), // Placeholder image
                                    ),
                                    title: Text(userData
                                        .username), // Display viewer's username
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_viewers.isNotEmpty)
                              Text(
                                'Viewed by: ${_viewers.length}', // Show the count of viewers
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              child: EyeViews(countViews: _viewers.length),
            ),
        ],
      ),
    );
  }
}
