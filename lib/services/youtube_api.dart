import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum OrderFilter { date, rating, relevance, title, viewCount, def }

enum VideoDuration { any, long, medium, short }

class YouTubeApi {
  static String youtubeApiUrl = 'https://www.googleapis.com/youtube/v3';

  late Map<String, dynamic> searchFilter;
  late List<Map<String, dynamic>> searchResult;

  late String nextPageToken;

  YouTubeApi() {
    nextPageToken = '';
    searchResult = [];

    searchFilter = {
      "maxResults": 10,
      "order": OrderFilter.def,
      "publishedAfter": null,
      "publishedBefore": null,
      "safeSearch": false,
      "videoDuration": VideoDuration.any,
    };
  }

  Future<void> search(String searchQuery, bool loadNext) async {
    String searchUrl =
        '$youtubeApiUrl/search?key=${dotenv.env['API_KEY']}&q=$searchQuery&maxResults=${searchFilter['maxResults']}&type=video';

    if (loadNext) {
      searchUrl = '$searchUrl&pageToken=$nextPageToken';
    }

    if (!loadNext) {
      searchResult = [];
    }

    final searchResponse = await http.get(Uri.parse(searchUrl));

    if (searchResponse.statusCode == 200) {
      final searchResultJson = json.decode(searchResponse.body);

      nextPageToken = searchResultJson['nextPageToken'];

      searchResult = [...searchResult, ...searchResultJson['items']];

      // print(searchResult);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
