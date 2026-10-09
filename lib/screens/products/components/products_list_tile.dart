import 'package:flutter/material.dart';
import 'package:loja_virtual_pro/models/product.dart';

class ProductListTile extends StatelessWidget {

  const ProductListTile(this.product, {super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4)
      ),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: product.images.isEmpty
                  ? const Icon(Icons.image_not_supported, color: Colors.grey)
                  : Image.network(
                      product.images.first,
                      // Na web, usa <img> quando o servidor da imagem não libera CORS.
                      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16,),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'A partir de',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ 19.99',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).primaryColor
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}