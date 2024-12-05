import 'dart:convert';
import 'package:chatoid/presntation/screens/stories/story_element.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomePageStoryPosts extends StatefulWidget {
  const HomePageStoryPosts({super.key});

  @override
  HomePageStoryPostsState createState() => HomePageStoryPostsState();
}

class HomePageStoryPostsState extends State<HomePageStoryPosts> {
  List<dynamic> newsPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNewsPosts();
    newsPosts.shuffle(); // Shuffle the posts after fetching
  }

  Future<void> fetchNewsPosts() async {
    const String apiUrl =
        'https://gnews.io/api/v4/top-headlines?country=eg&category=world&apikey=42af49a4b6c0e4bd81d0def05c51a72a';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        setState(() {
          newsPosts = data['articles'] ?? [];
          isLoading = false;
        });
        if (newsPosts.isNotEmpty) {
          print('First post: ${newsPosts[0]}');
          print('Total fetched posts: ${newsPosts.length}');
        } else {
          print('No news posts available.');
        }
      } else {
        print('Response code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load news');
      }
      newsPosts.shuffle();
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching news: ${error.toString()}');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });
    await fetchNewsPosts(); // Fetch the latest posts
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          const StoryList(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(
              indent: 10,
              endIndent: 10,
              thickness: 2,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: newsPosts.length,
              itemBuilder: (context, index) {
                final newsItem = newsPosts[index];
                return Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Publisher Info
                      Row(
                        children: [
                          // Profile GIF
                          ClipOval(
                            child: Image.asset(
                              'assets/profile.gif',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Publisher Name
                          Text(
                            newsItem['source']['name'] ?? 'Unknown Publisher',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Title
                      Text(
                        newsItem['title'] ?? 'No Title',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      // Content (show full description)
                      Text(
                        newsItem['content'] ?? 'No Content Available',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      // Date
                      Text(
                        newsItem['publishedAt'] != null
                            ? DateTime.parse(newsItem['publishedAt'])
                                .toLocal()
                                .toString()
                            : 'Unknown Date',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      // Image (make it bigger)
                      if (newsItem['image'] !=
                          null) // Assuming you meant 'image'
                        Container(
                          height: 250, // Adjust height as needed
                          width: double.infinity,
                          child: Image.network(
                            newsItem['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return const Center(
                                child: Text(
                                  'Image not available',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 5),
                      // URL Link
                      TextButton(
                        onPressed: () async {
                          try {
                            if (await canLaunch(newsItem['url'] ?? '')) {
                              await launch(newsItem['url'] ?? '');
                            } else {
                              throw 'Could not launch ${newsItem['url']}';
                            }
                          } catch (e) {
                            print('Error launching URL: $e');
                          }
                        },
                        child: const Text('Read more',
                            style: TextStyle(color: Colors.blue)),
                      ),
                      const SizedBox(height: 10),
                      // Action Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up),
                                onPressed: () {
                                  // Handle like action
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.comment),
                                onPressed: () {
                                  // Handle comment action
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  // Handle share action
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
