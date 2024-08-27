import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class FadeInCircularAvatar extends StatelessWidget {
  final String url;
  final double radius;

  const FadeInCircularAvatar({required this.url, this.radius=20, super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(radius)),
                    child: FadeInImage(
                      width: radius*2, 
                      height: radius*2,
                      placeholder:  MemoryImage(kTransparentImage),
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    )
                  );
  }

}