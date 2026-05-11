import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

http.Client getClient() => BrowserClient()..withCredentials = true;
