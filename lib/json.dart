import 'dart:convert';

import 'package:flutter/foundation.dart';

class ProjectInfo {
  final String project_number;
  final String project_id;
  final String storage_bucket;

  ProjectInfo({
      required this.project_number,
      required this.project_id,
      required this.storage_bucket
  });

  factory ProjectInfo.fromJson(Map<String, dynamic> json) {
    final project_number = json["project_number"];
    final project_id = json["project_id"];
    final storage_bucket = json["storage_bucket"];
    return ProjectInfo(project_number: project_number, project_id: project_id, storage_bucket: storage_bucket);
  }
}

class ProjectResponse {
  final ProjectInfo project_number_info, project_id_info, storage_bucket_info;

  ProjectResponse({
    required this.project_number_info,
    required this.project_id_info,
    required this.storage_bucket_info
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {

    final project_number_info_json = json["project_info"];
    final project_number_info = ProjectInfo.fromJson(project_number_info_json);

    final project_id_info_json = json["project_info"];
    final project_id_info = ProjectInfo.fromJson(project_id_info_json);

    final storage_bucket_info_json = json["project_info"];
    final storage_bucket_info = ProjectInfo.fromJson(storage_bucket_info_json);

    return ProjectResponse(
        project_number_info: project_number_info,
        project_id_info: project_id_info,
        storage_bucket_info: storage_bucket_info
    );
  }
}

class Util {

  Future<ProjectResponse> parseJsonConfig(String rawJson) async {
    final Map<String, dynamic> parsed = await compute(decodeJsonWithCompute, rawJson);
    final projectResponse= ProjectResponse.fromJson(parsed);
    return projectResponse;
  }

  static Map<String, dynamic> decodeJsonWithCompute(String rawJson) {
    return jsonDecode(rawJson);
  }

}