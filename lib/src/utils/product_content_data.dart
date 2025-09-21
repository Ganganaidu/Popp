const List<String> bikeBrands = [
  'Aprilia',
  'Bajaj',
  'Benelli',
  'BMW Motorrad',
  'CFMoto',
  'Ducati',
  'Harley-Davidson',
  'Honda',
  'Husqvarna',
  'Jawa',
  'Kawasaki',
  'Keeway',
  'KTM',
  'Moto Guzzi',
  'MV Agusta',
  'Royal Enfield',
  'Suzuki',
  'Triumph',
  'TVS',
  'Yamaha',
  'Yezdi',
  'Zontes',
];

const Map<String, List<String>> bikeBrandModels = {
  'Royal Enfield': [
    'Interceptor 650',
    'Continental GT 650',
    'Super Meteor 650',
    'Shotgun 650',
  ],
  'KTM': [
    '690 Duke',
    '690 Enduro R',
    '790 Duke',
    '890 Duke',
    '1290 Super Duke R',
    '1290 Super Adventure',
  ],
  'Bajaj': [
    // Bajaj itself doesn't have premium >200cc standalone models.
    // Collaborates with KTM.
  ],
  'TVS': [
    'Apache RR 310',
    'Apache RTR 310',
  ],
  'Yamaha': [
    'MT-07',
    'MT-09',
    'YZF-R7',
    'YZF-R1',
    'XSR700',
    'Tenere 700',
  ],
  'Suzuki': [
    'SV650',
    'GSX-S750',
    'GSX-S1000',
    'Hayabusa',
    'V-Strom 650',
  ],
  'Honda': [
    'CB650R',
    'CBR650R',
    'CBR500R',
    'CB1000R',
    'Africa Twin 1100',
    'CBR1000RR-R',
  ],
  'Kawasaki': [
    'Z650',
    'Z900',
    'Z H2',
    'Ninja 650',
    'Ninja ZX-6R',
    'Ninja ZX-10R',
    'Versys 650',
    'Ninja H2',
  ],
  'Triumph': [
    'Street Triple 765',
    'Speed Triple 1200',
    'Tiger 900',
    'Tiger 1200',
    'Bonneville T120',
    'Rocket 3',
  ],
  'Harley-Davidson': [
    'Sportster S',
    'Street Glide',
    'Fat Boy',
    'Pan America 1250',
  ],
  'BMW Motorrad': [
    'F 900 R',
    'S 1000 R',
    'S 1000 RR',
    'R 1250 GS',
    'K 1600 GTL',
  ],
  'Ducati': [
    'Monster 937',
    'Panigale V2',
    'Panigale V4',
    'Multistrada V4',
    'Diavel V4',
  ],
  'Benelli': [
    'Leoncino 800',
    'TRK 800',
  ],
  'CFMoto': [
    '650MT',
    '700 CL-X',
  ],
  'Husqvarna': [
    '701 Supermoto',
    '701 Enduro',
    'Norden 901',
  ],
  'Jawa': [
    'Perak',
    '42 Bobber',
  ],
  'Yezdi': [
    'Adventure',
    'Scrambler',
    'Roadster',
  ],
  'Aprilia': [
    'RS 660',
    'Tuono 660',
    'Tuono V4',
    'RSV4 1100',
  ],
  'Moto Guzzi': [
    'V7 Stone',
    'V9 Bobber',
    'V85 TT',
  ],
  'MV Agusta': [
    'Brutale 800',
    'Brutale 1000',
    'F3 800',
    'Turismo Veloce 800',
  ],
  'Zontes': [
    '350T',
    '350X',
    '350R',
    'GK350',
  ],
  'Keeway': [
    'V302C',
    'K-Light 250V',
    'RK V1250',
  ],
};

const bikeFilters = [
  'Budget',
  'Brand / Model',
  'By KM Driven',
  'By State',
  'By Year',
];

const categoryFilters = [
  'Budget',
  'By Category',
  'By SubCategory',
  'By State',
  'By Year',
];

const List<String> countryCodes = ["+91", "+1"];

const List<String> yesNo = ["Yes", "No"];
const List<String> yesNoNA = ["Yes", "No", "N/A"];
const List<String> goodBadList = ["Good", "Need replacement"];
const List<String> tyreConditionList = [
  "Good",
  "Half life",
  "Need replacement"
];

const List<String> productConditionList = [
  "New",
  "Openbox",
  "Used",
  "Unused",
  "Good",
  "Fair",
  "Poor"
];

const List<String> stateNames = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chandigarh',
  'Chhattisgarh',
  'Delhi',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jammu and Kashmir',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Ladakh',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Puducherry',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
];

const Map<String, Map<String, double>> stateCoordinates = {
  'Andhra Pradesh': {'lat': 15.9129, 'lon': 79.7400},
  'Telangana': {'lat': 18.1124, 'lon': 79.0193},
  'Assam': {'lat': 26.2006, 'lon': 92.9376},
  'Bihar': {'lat': 25.0961, 'lon': 85.3131},
  'Chhattisgarh': {'lat': 21.2787, 'lon': 81.8661},
  'Chandigarh': {'lat': 30.7333, 'lon': 76.7794},
  'Delhi': {'lat': 28.6139, 'lon': 77.2090},
  'Goa': {'lat': 15.2993, 'lon': 74.1240},
  'Gujarat': {'lat': 22.2587, 'lon': 71.1924},
  'Haryana': {'lat': 29.0588, 'lon': 76.0856},
  'Himachal Pradesh': {'lat': 31.1048, 'lon': 77.1734},
  'Jammu and Kashmir': {'lat': 33.7782, 'lon': 76.5762},
  'Jharkhand': {'lat': 23.6102, 'lon': 85.2799},
  'Karnataka': {'lat': 15.3173, 'lon': 75.7139},
  'Kerala': {'lat': 10.8505, 'lon': 76.2711},
  'Ladakh': {'lat': 34.2268, 'lon': 77.5619},
  'Madhya Pradesh': {'lat': 22.9734, 'lon': 78.6569},
  'Maharashtra': {'lat': 19.7515, 'lon': 75.7139},
  'Manipur': {'lat': 24.6637, 'lon': 93.9063},
  'Meghalaya': {'lat': 25.4670, 'lon': 91.3662},
  'Mizoram': {'lat': 23.1645, 'lon': 92.9376},
  'Nagaland': {'lat': 26.1584, 'lon': 94.5624},
  'Odisha': {'lat': 20.9517, 'lon': 85.0985},
  'Punjab': {'lat': 31.1471, 'lon': 75.3412},
  'Puducherry': {'lat': 11.9416, 'lon': 79.8083},
  'Rajasthan': {'lat': 27.0238, 'lon': 74.2179},
  'Sikkim': {'lat': 27.5330, 'lon': 88.5122},
  'Tamil Nadu': {'lat': 11.1271, 'lon': 78.6569},
  'Tripura': {'lat': 23.9408, 'lon': 91.9882},
  'Uttar Pradesh': {'lat': 26.8467, 'lon': 80.9462},
  'Arunachal Pradesh': {'lat': 28.2180, 'lon': 94.7278},
  'Uttarakhand': {'lat': 30.0668, 'lon': 79.0193},
  'West Bengal': {'lat': 22.9868, 'lon': 87.8550},
};

const List<String> serviceCategories = [
  'Book your Bike service', // Find your mechanic
  'Bike Rentals',
  'Track day',
  'Training day',
];

const List<String> riderSkillLevels = [
  'All',
  'Beginner',
  'Novice',
  'Intermediate',
  'Expert'
];
