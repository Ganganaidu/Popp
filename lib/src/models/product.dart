class Product {
  final String imageUrl;
  final String title;
  final String priceRange;
  final bool isProductInStock;

  Product({
    required this.imageUrl,
    required this.title,
    required this.priceRange,
    required this.isProductInStock,
  });
}

final List<Product> productList = [
  Product(
      imageUrl:
          "https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80",
      title: "ORazo IBIS",
      priceRange: "RS.1,9500.00",
      isProductInStock: true),
  Product(
      imageUrl:
          "https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80",
      title: "MT Thunder 4",
      priceRange: "RS.1,9500.00",
      isProductInStock: false),
  Product(
      imageUrl:
          "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80",
      title: "MT Thunder3 PRO ISLE OF MAN",
      priceRange: "RS.1,9500.00",
      isProductInStock: true),
  Product(
      imageUrl:
          "https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80",
      title: "MT Thunder3 PRO",
      priceRange: "RS.1,9500.00",
      isProductInStock: true),
  Product(
      imageUrl:
          "https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80",
      title: "REvt's Eclips Mesh Jacket",
      priceRange: "RS.1,9500.00",
      isProductInStock: true)
];

