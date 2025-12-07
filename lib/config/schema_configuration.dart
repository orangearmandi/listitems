class SchemaConfiguration {
  final ConfigurationEndpoints endpoints;

  SchemaConfiguration({required this.endpoints});
}

class ConfigurationEndpoints {
  final String listItems;
  final String userProfile;
  ConfigurationEndpoints({required this.listItems, required this.userProfile});
}
