library wallpaperoftheweek;

import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

part 'wallpaper.dart';

main() {
  final String url = "http://magic.wizards.com/en/articles/wallpapers";
  final String destination = "/Users/billc/Dropbox/Images/magic_wallpaper/";

  http.read(url).then(selectWallpapers).then((wallpapers) => prune(wallpapers, destination)).then((wallpapers) => Future.forEach(wallpapers, process));
}

Set<String> selectWallpapers(String response) {
  RegExp exp = new RegExp(r"http[\S]+files\/images\/wallpaper\/[\S]*2560[\S]+.jpg");
  Iterable<Match> matches = exp.allMatches(response);

  Set images = new Set();
  for (Match m in matches) {
    images.add(m.group(0));
  }

  Set wallpapers = new Set();
  for (String s in images) {
    wallpapers.add(new Wallpaper(s, path.basename(s)));
  }

  return wallpapers;
}

Set prune(Set wallpapers, String destination) {
  Set pruned = new Set();

  for (Wallpaper wp in wallpapers) {
    var f = new File("/Users/billc/Dropbox/Images/magic_wallpaper/${wp.name}");
    if (!f.existsSync()) {
      print("New wallpaper found: ${wp.name}");
      pruned.add(wp);
    }
  }

  print("Found ${pruned.length} new wallpapers");
  return pruned;
}

// Retrieve the wallpaper from the URL and save to the local target location

Future process(Wallpaper wp) {
  print("Retrieving ${wp.source}");
  return http.readBytes(wp.source).then((image) => saveImage(wp.name, image));

}

void saveImage(String name, var data) {
  new File("/Users/billc/Dropbox/Images/magic_wallpaper/${name}")
    ..writeAsBytesSync(data);
  print("Saving $name");
}
