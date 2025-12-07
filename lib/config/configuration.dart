import '../../config/schema_configuration.dart';

class ConfigurationApiList {
  final String apiBaseUrl =
      'https://wrapped-alt-comprehensive-identifier.trycloudflare.com';
  late final SchemaConfiguration _config;
  ConfigurationApiList() {
    _config = SchemaConfiguration(
      endpoints: ConfigurationEndpoints(
        listItems: '$apiBaseUrl/api/collections/list/records',
        userProfile:
            '$apiBaseUrl/api/collections/users/records', // post,delete,get,patch (no used)
      ),
    );
  }

  SchemaConfiguration get config => _config;
}
