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
        '$youtubeApiUrl/search?key=${dotenv.env['API_KEY']}&q=$searchQuery&maxResults=${searchFilter['maxResults']}&type=video&part=snippet';

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

      List<dynamic> searchData = searchResultJson['items'];
      List<Map<String, dynamic>> searchDataList = [];

      for (int i = 0; i < searchData.length; i++) {
        String videoId = searchData[i]['id']['videoId'];
        String videoTitle = searchData[i]['snippet']['title'];
        String thumbnailUrl = searchData[i]['snippet']['thumbnails']['default']['url'];
        int thumbnailWidth = searchData[i]['snippet']['thumbnails']['default']['width'];
        int thumbnailHeight = searchData[i]['snippet']['thumbnails']['default']['height'];

        searchDataList.add({
          "videoId": videoId,
          "title": videoTitle,
          "thumbnailUrl": thumbnailUrl,
          "thumbnailWidth": thumbnailWidth.toDouble(),
          "thumbnailHeight": thumbnailHeight.toDouble()
        });
      }

      searchResult = [...searchResult, ...searchDataList];

    } else {
      throw Exception('Failed to load data');
    }
  }
}
