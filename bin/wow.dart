import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';


main() {
  var url = "http://magic.wizards.com/en/articles/wallpapers";

  String targetLocation = "/Users/billc/Dropbox/Images/magic_wallpaper/";
  http.read(url).then(selectWallpaper)
//    .then((Set<String> wallpapers) => removeExisting(wallpapers, targetLocation))
  .then((loc) => Future.forEach(loc, retrieveImage));
}

Set<String> selectWallpaper(String response) {
  RegExp exp = new RegExp(r"http[\S]+files\/images\/wallpaper\/[\S]*2560[\S]+.jpg");
  Iterable<Match> matches = exp.allMatches(response);

  Set images = new Set();

  for (Match m in matches) {
    images.add(m.group(0));
  }

  return images;
}

// Retrieve the wallpaper from the URL and save to the local target location

Future retrieveImage(String location) {
  Uri uri = Uri.parse(location);
  String name = uri.pathSegments.last;

  print("Retrieving $location");
  return http.readBytes(location).then((image) => saveImage(name, image));

}

void saveImage(String name, var data) {
  new File("/Users/billc/Dropbox/Images/magic_wallpaper/${name}")
    ..writeAsBytesSync(data);
  print("Saving $name");
}

Set removeExisting(Set wallpapers, String location) {
  print("${wallpapers.length} wallpapers available");

  Directory d = new Directory(location);
  Set existing = d.listSync().toSet();

  print("${existing.length} existing wallpapers found");
  existing.forEach(print);

  Set available = new Set();
  for (var w in wallpapers) {
    if (!exists(w, existing)) {
      available.add(w);
    }
  }

  print("Found ${available.length} new wallpapers to retrieve");
  available.forEach(print);
  print("\n\n");


  return available;
}

bool exists(String s, Set e) {
  String name = Uri.parse(s).pathSegments.last;
  print("${e.contains(name)} $name");
  return e.contains(name);
}
