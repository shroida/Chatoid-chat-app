import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/profile/view/profile.dart';
import 'package:chatoid/features/register/view_model/signUp/signup_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: theme.hintColor),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: BlocProvider.of<SignupCubit>(context, listen: false)
          .searchUsernames(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(), // Modern spinner
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 80,
                    color: Colors.grey[500]), // Modern icon for "no results"
                const SizedBox(height: 10),
                const Text(
                  'No results found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final List<String> matchQuery = snapshot.data!;

        return ListView.builder(
          itemCount: matchQuery.length,
          itemBuilder: (context, index) {
            final result = matchQuery[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey[100], // Example avatar style
                child: Text(
                    result[0].toUpperCase()), // First letter as avatar text
              ),
              title: Text(result, style: const TextStyle(fontSize: 16)),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey[600]),
              onTap: () async {
                UserData selectedUser = await BlocProvider.of<LoginCubit>(
                  context,
                  listen: false,
                ).getUserByUsername(result) as UserData;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(userProfile: selectedUser),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final chatsCubit = Provider.of<ChatsCubit>(context, listen: false);
    List<UserData> friendsList = chatsCubit.friendsList;

    final List<UserData> filteredSuggestions = friendsList.where((user) {
      final queryLower = query.toLowerCase();
      return user.username.toLowerCase().contains(queryLower);
    }).toList();

    // If no friends match the search, show a message
    if (filteredSuggestions.isEmpty) {
      return const Center(child: Text('No friends found.'));
    }

    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = filteredSuggestions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueGrey[100], // Example avatar style
            child: Text(
              suggestion.username[0]
                  .toUpperCase(), // First letter as avatar text
              style: const TextStyle(color: Colors.black),
            ),
          ),
          title: Text(suggestion.username,
              style:
                  const TextStyle(fontSize: 16)), // Display friend's username
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[600], // Subtle arrow icon
          ),
          onTap: () async {
            // Fetch user details from Supabase based on the selected username
            final selectedUser = await Provider.of<LoginCubit>(
              context,
              listen: false,
            ).getUserByUsername(suggestion.username);

            if (selectedUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(userProfile: selectedUser),
                ),
              );
            }
          },
        );
      },
    );
  }
}
