import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository extends ChangeNotifier {
  // Constructor for ChatRepository (you don't need to instantiate _repo here)
  ChatRepository();

  void channel() {
    final supabase = Supabase.instance;
    final channels = supabase.client.realtime.getChannels();

    channels.map((e) {
    }).toList(); 
  }
}
