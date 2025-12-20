import 'package:http/http.dart' as http;

import '../util/github_config.dart';

class GitHubService {
  static Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer ${GitHubConfig.TOKEN}',
      'Accept': 'application/vnd.github.v3+json',
    };
  }

  Future<http.Response> getRepositoryData(List<String> formattedData) async {
    return http.get(
      Uri.parse("https://api.github.com/repos/${formattedData[3]}/${formattedData[4]}"),
      headers: _getHeaders(),
    );
  }

  Future<http.Response> getRepositoryLatestReleaseData(List<String> formattedData) async {
    return http.get(
      Uri.parse("https://api.github.com/repos/${formattedData[3]}/${formattedData[4]}/releases/latest"),
      headers: _getHeaders(),
    );
  }
}
