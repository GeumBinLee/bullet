const String layoutEntryPrefix = 'entry:';
const String layoutComponentPrefix = 'component:';

String layoutEntryToken(String entryId) => '$layoutEntryPrefix$entryId';
String layoutComponentToken(String componentId) =>
    '$layoutComponentPrefix$componentId';


