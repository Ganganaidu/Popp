import '../models/product.dart';

List<Product> productList = [
  Product(
      userId: "uid",
      id: 'P001',
      categoryId: 'C001',
      subCategoryName: '',
      categoryName: '',
      expectedPrice: "123,000",
      brandName: 'Honda',
      modelName: 'Activa 6G',
      imageUrl:
          "https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      thumbImageUrls: [
        'https://images.unsplash.com/photo-1611429532458-f8bf8f6121fe?q=80&w=3079&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135825-d34b40aa03ef?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1643111441058-24775743af1c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1638003299152-dd1e3bf81fa5?q=80&w=2242&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1558981033-0f0309284409?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
      ],
      additionalDetails: '',
      firstOwner: '',
      kmDriven: '',
      mfgDate: DateTime(2021, 5, 10),
      invoiceAvailable: "NO",
      registrationDate: DateTime(2021, 6, 15),
      registrationPlace: 'Bangalore, Karnataka',
      city: 'Bangalore',
      state: 'Karnataka',
      nocAvailable: "No",
      insuranceAvailable: "Yes",
      insuranceValidTill: DateTime(2021, 6, 15),
      sellerName: 'John Doe',
      sellerContactNumber: '9876543210',
      isFavorite: true),
  Product(
      userId: "userId",
      id: 'P002',
      categoryName: '',
      subCategoryName: '',
      categoryId: 'C001',
      brandName: 'Hero',
      expectedPrice: "120000",
      modelName: 'Splendor Plus',
      imageUrl:
          "https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      thumbImageUrls: [
        'https://images.unsplash.com/photo-1622185135825-d34b40aa03ef?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1611429532458-f8bf8f6121fe?q=80&w=3079&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1643111441058-24775743af1c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      mfgDate: DateTime(2018, 11, 20),
      invoiceAvailable: 'Yes',
      registrationDate: DateTime(2019, 1, 5),
      registrationPlace: 'Mumbai, Maharashtra',
      city: 'Mumbai',
      state: 'Maharashtra',
      nocAvailable: 'Yes',
      insuranceAvailable: 'Yes',
      insuranceValidTill: DateTime(2021, 6, 15),
      sellerName: 'Jane Smith',
      sellerContactNumber: '8765432109',
      additionalDetails: '',
      firstOwner: '',
      kmDriven: '',
      isFavorite: false),
  Product(
      userId: "id",
      id: 'P003',
      categoryName: '',
      subCategoryName: '',
      categoryId: 'C002',
      brandName: 'Maruti Suzuki',
      modelName: 'Swift Dzire',
      imageUrl:
          "https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      thumbImageUrls: [
        'https://images.unsplash.com/photo-1643111441058-24775743af1c?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135505-2d795003994a?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1611429532458-f8bf8f6121fe?q=80&w=3079&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1622185135825-d34b40aa03ef?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      mfgDate: DateTime(2020, 5, 10),
      invoiceAvailable: 'Yes',
      registrationDate: DateTime(2020, 6, 15),
      city: 'Mumbai',
      state: 'Maharashtra',
      registrationPlace: 'Delhi',
      nocAvailable: 'Yes',
      insuranceAvailable: 'Yes',
      insuranceValidTill: DateTime(2021, 6, 15),
      expectedPrice: '700000.00',
      sellerName: 'Alex',
      sellerContactNumber: '9876543210',
      additionalDetails: '',
      firstOwner: '',
      kmDriven: '',
      isFavorite: false)
];

// Helmet
// https://images.unsplash.com/photo-1627530980937-b8721b91506a?q=80&w=3165&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1586423702505-b13505519074?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1575396565848-e8031f12ce2a?q=80&w=3125&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
// https://images.unsplash.com/photo-1623038868323-7d39ec58eefe?q=80&w=2000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D
