const List<String> bikeBrands = [
  'Royal Enfield',
  'KTM',
  'Bajaj',
  'TVS',
  'Yamaha',
  'Suzuki',
  'Honda',
  'Kawasaki',
  'Triumph',
  'Harley-Davidson',
  'BMW Motorrad',
  'Ducati',
  'Benelli',
  'CFMoto',
  'Husqvarna',
  'Jawa',
  'Yezdi',
  'Aprilia',
  'Moto Guzzi',
  'MV Agusta',
  'Zontes',
  'Keeway',
  'others'
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
  'Sort By'
];

const categoryFilters = [
  'Budget',
  'By Category',
  'By SubCategory',
  'By State',
  'By Year',
  'Sort By'
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
  'Telangana',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Chandigarh',
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
  'Punjab',
  'Puducherry',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Tripura',
  'Uttar Pradesh',
  'Arunachal Pradesh',
  'Uttarakhand',
  'West Bengal',
];

const List<String> serviceCategories = [
  'Book your Bike service',
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
