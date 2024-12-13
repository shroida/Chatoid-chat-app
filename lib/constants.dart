import 'package:flutter/material.dart';

const mySupakey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVodXNodG9vaGJma2d3Y3RnYWtoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2NjczMDgsImV4cCI6MjA0MjI0MzMwOH0.709yDvDz8nVhsVW7CkbF6np1a5s7dzChZPOFQ16BUg8';
const urlSupa = 'https://ehushtoohbfkgwctgakh.supabase.co';
const oneSignal='e1416184-6af7-4fcc-8603-72e042e1718d';
// Define your light mode theme
final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  // Add other light mode configurations
);

// Define your dark mode theme
final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blueGrey,
  // Add other dark mode configurations
);

class ChatAppColors {
  static const Color primaryColor =
      Color(0xFF1E3A8A); // Bright Blue for main actions
  static const Color primaryColor2 =
      Color(0xFFB30BAA); // Bright Blue for main actions
  static const Color primaryColor3 =
      Color(0xFF0B9B88); // Bright Blue for main actions
  static const Color primaryColor4 =
      Color(0xFFBE0C0C); // Bright Blue for main actions
  static const Color primaryColor5 =
      Color(0xFFBCD100); // Bright Blue for main actions
  static const Color primaryColor6 =
      Color(0xFF604CD4); // Bright Blue for main actions
  static const Color primaryColor7 =
      Color(0xFF4ADE80); // Bright Blue for main actions
  static const Color primaryColor8 =
      Color.fromARGB(255, 2, 141, 234); // Bright Blue for main actions
  static const Color secondaryColor =
      Color(0xFF8338EC); // Vibrant Purple for highlights
  static const Color accentColor =
      Color(0xFFFB5607); // Energetic Orange for buttons and accents

  // Background and surfaces
  static const Color backgroundColor =
      Color(0xFFF1F5F9); // Soft grayish-white background
  static const Color backgroundColorDark =
      Color(0xFF36383A); // Soft grayish-white background

  static const Color chatBubbleColorSender =
      Color(0xFFD0EFFF); // Soft Blue for sender bubble
  static const Color chatBubbleColorReceiver =
      Color(0xFFF8F9FA); // Almost white for receiver bubble

  // Text colors
  static const Color chatTextColorSender =
      Color(0xFF343A40); // Dark Gray for sender text
  static const Color chatTextColorReceiver =
      Color(0xFF495057); // Medium Gray for receiver text
  static const Color timestampColor =
      Color(0xFF6C757D); // Subtle gray for timestamps

  static const Color onlineIndicatorColor =
      Color(0xFF4ADE80); // Fresh Green for online status

  // AppBar and Icons
  static const Color appBarColor =
      Color(0xFF1E3A8A); // Deep Blue for app bar to show security and trust
  static const Color iconColor =
      Color(0xFFFFFFFF); // White icons for clarity and contrast

  // Additional Modern Colors
  static const Color messageStatusColor =
      Color(0xFF00B4D8); // Light Blue for message sent/read status
  static const Color dividerColor =
      Color(0xFFE0E0E0); // Soft divider between chat bubbles
}

const List<String> profilesImages = [
  'assets/girl1.gif',
  'assets/girl2.gif',
  'assets/girl3.gif',
  'assets/boy1.gif',
  'assets/profile.gif',
];
