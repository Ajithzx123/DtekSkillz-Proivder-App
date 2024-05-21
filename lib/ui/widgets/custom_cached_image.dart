import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage(
      {super.key, required this.imageUrl, this.width, this.height, this.fit,});

  final String imageUrl;
  final double? width, height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return imageUrl.endsWith('.svg')
        ? SvgPicture.network(
            imageUrl,
            fit: BoxFit.fill,
            width: width,
            height: height,
            colorFilter:
                ColorFilter.mode(Theme.of(context).colorScheme.accentColor, BlendMode.srcIn),
            placeholderBuilder: (BuildContext context) {
              return SizedBox(
                width: width ?? 100,
                height: height ?? 100,
                child: Image.asset('${Constant.pngPath}placeholder.png', fit: BoxFit.contain),
              );
            },
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit ?? BoxFit.contain,
            errorWidget: (BuildContext context, String url, error) {
              return SizedBox(
                width: width,
                height: height,
                child: Image.asset('${Constant.pngPath}noImageFound.png', fit: BoxFit.contain),
              );
            },
            placeholder: (BuildContext context, String url) {
              return SizedBox(
                width: width ?? 100,
                height: height ?? 100,
                child: Image.asset('${Constant.pngPath}placeholder.png', fit: BoxFit.contain),
              );
            },
          );
  }
}
