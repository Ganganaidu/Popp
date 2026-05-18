/**
 * Static reference data ported 1-to-1 from Flutter:
 *   lib/src/services/bikes/sell_your_bike.dart
 *   lib/src/services/accessories/sell_your_accessories.dart
 *   lib/src/services/listservices/list_service_form_screen.dart
 *   lib/src/models/product.dart
 *
 * Keep in sync with the Dart source — never guess field names.
 */

/* ── Seller ───────────────────────────────────────────────────────────────── */
export const SELLER_CATEGORIES = ['Individual', 'Business'] as const;
export const COUNTRY_CODES     = ['+91', '+1'] as const;

/* ── Bike brands + models ─────────────────────────────────────────────────── */
export const BIKE_BRANDS = [
  'Hero', 'Bajaj', 'TVS', 'Royal Enfield', 'Jawa', 'Yezdi', 'BSA',
  'Aprilia', 'Honda', 'Suzuki', 'Yamaha', 'KTM', 'Kawasaki',
  'Harley-Davidson', 'BMW', 'Triumph', 'Ducati', 'MV Agusta', 'Norton',
  'Indian', 'Benelli', 'CFMoto', 'Brixton', 'Husqvarna', 'Moto Morini',
  'Zontes', 'QJ Motor', 'Benda', 'Others',
] as const;

export type BikeBrand = typeof BIKE_BRANDS[number];

export const BIKE_MODELS: Record<string, string[]> = {
  'Hero':            ['Xtreme 250R', 'Karizma XMR 250', 'Mavrick 440', 'Xpulse 200', 'Xpulse 200 4V', 'Xpulse 210'],
  'Bajaj':           ['Dominar 250', 'Dominar 400', 'Pulsar N250', 'Pulsar NS400Z'],
  'TVS':             ['Apache RTX 300', 'Apache RTR 310', 'Apache RR 310'],
  'Royal Enfield':   [
    'Hunter 350', 'Bullet 350', 'Classic 350', 'Meteor 350', 'Goan Classic 350',
    'Scram 440', 'Guerrilla 450', 'Himalayan 450', 'Interceptor 650', 'Continental GT 650',
    'Classic 650', 'Bear 650', 'Shotgun 650', 'Super Meteor 650', 'Bullet 650',
    'Scram 411', 'Himalayan 411', 'Classic 500', 'Bullet 500', 'Bullet Trials 350',
    'Bullet Trials 500', 'Thunderbird 350', 'Thunderbird 350X', 'Thunderbird 500', 'Thunderbird 500X',
  ],
  'Jawa':            ['42 (295 cc)', '350 (334 cc)', '42 FJ (334 cc)', '42 Bobber (334 cc)', 'Perak (334 cc)'],
  'Yezdi':           ['Roadster (334 cc)', 'Adventure (334 cc)', 'Scrambler (334 cc)'],
  'BSA':             ['Gold Star 650', 'Scrambler 650'],
  'Aprilia':         [
    'RS 457', 'Tuono 457', 'RS 660', 'Tuono 660', 'Tuareg 660',
    'RSV4 1100 Factory', 'Tuono V4 Rs', 'RS4', 'Dorsoduro 1200', 'Caponord 1200',
    'Mana 850', 'SRV 850', 'Shiver 900', 'Shiver 750', 'Dorsoduro 900',
  ],
  'Honda':           [
    'CB300F', 'CB350', 'CB350RS', 'CB350C', "H'ness CB350", 'NX500',
    'CBR650R', 'CB650R', 'XL750 Transalp', 'CB750 Hornet', 'CB1000 Hornet',
    'Rebel 500', 'CB200X', 'Hornet 2.0', 'GOLDWING',
  ],
  'Suzuki':          [
    'Gixxer 250', 'Gixxer SF 250', 'V-Strom SX (249 cc)', 'GSX-8R',
    'V-Strom 650', 'V-Strom 800DE', 'Hayabusa', 'Inazuma 250',
    'V-Strom 650XT', 'V-Strom 1000', 'GSX-R1000', 'GSX-S1000', 'GSX-S750', 'GSX-SF1000', 'Katana',
  ],
  'Yamaha':          ['MT-03', 'R3', 'FZ25', 'Fazer 25', 'R1'],
  'KTM':             [
    '200 Duke', '250 Duke', '390 Duke', 'RC 200', 'RC 390',
    '250 Adventure', '390 Adventure', '390 Adventure X', '390 Adventure R',
    '890 Duke R', '1290 Super Adventure S', 'Duke 690', 'Duke 790', 'Dirt Bike',
  ],
  'Kawasaki':        [
    'Ninja 250R', 'Ninja 300', 'Ninja 400', 'Ninja 500', 'Ninja 650',
    'Ninja ZX-6R', 'Ninja ZX-10R', 'Ninja 1000SX', 'Ninja 1100SX',
    'Z650', 'Z650RS', 'ER-6n 650', 'Z800', 'Z900', 'Z900RS',
    'Vulcan S', 'Versys 650', 'Versys-X 300', 'Versys 1000', 'KLX 230', 'Dirt Bike',
  ],
  'Harley-Davidson': [
    'X440', 'X440 T', 'Nightster', 'Nightster Special', 'Sportster S',
    'Fat Boy', 'Breakout', 'Heritage Classic', 'Pan America 1250',
    'Street Glide', 'Road Glide', 'Street Bob', 'CVO Street Glide', 'CVO Road Glide',
    'Street 750', 'Street Rod 750', 'SuperLow', 'Fat Boy Special', '1200 Custom',
    'Electra Glide Standard', 'Low Rider S', 'Ultra Classic Electra Glide',
    'Deluxe', 'Road King', 'V-Rod', 'Forty-Eight Special', 'Fat Bob',
  ],
  'BMW':             [
    'G 310 R', 'G 310 GS', 'G 310 RR', 'R 1300 GS', 'R 1300 GS Adventure',
    'F 900 GS', 'F 900 GS Adventure', 'S 1000 RR', 'S 1000 R', 'S 1000 XR',
    'R 18', 'R 12 nineT', 'R 12', 'R 1200 RT', 'K 1600', 'C 400 GT',
    'F 750 GS', 'F 850 GS', 'F 850 GS Adventure', 'R 1250 GS', 'R 1250 GS Adventure', 'R 1250 RT',
  ],
  'Triumph':         [
    'Speed 400', 'Speed T4', 'Scrambler 400 X', 'Scrambler 400 XC', 'Thruxton 400',
    'Trident 660', 'Daytona 660', 'Daytona 675', 'Daytona 675R',
    'Street Triple', 'Street Triple R', 'Street Triple RS',
    'Speed Triple 1050', 'Speed Triple 1200', 'Speed Triple 1200 RS',
    'Speed Twin 900', 'Speed Twin 1200', 'Speed Twin 1200 RS',
    'Tiger Sport 660', 'Tiger 800 XR', 'Tiger 800 XC', 'Tiger 850 Sport',
    'Tiger 900 GT', 'Tiger 900 Rally Pro', 'Tiger 1200 Rally Pro',
    'Bonneville T100', 'Bonneville T120', 'Bonneville Speedmaster', 'Bonneville Bobber',
    'Scrambler 900', 'Scrambler 1200', 'Rocket 3', 'Thruxton R',
  ],
  'Ducati':          [
    'Panigale V4 R', 'Panigale V4', 'Streetfighter V4', 'Streetfighter V2',
    'SuperSport', 'Monster', 'XDiavel V4', 'Diavel V4',
    'Multistrada V4', 'Multistrada V4 RS', 'DesertX',
    'Hypermotard 950', 'Hypermotard 698 Mono',
    'Scrambler Icon', 'Scrambler Nightshift', 'Scrambler Full Throttle', 'Scrambler 1100',
    'Multistrada V2', 'Panigale V2', '959 Panigale', 'Monster 821', 'Panigale 1299',
  ],
  'MV Agusta':       [
    'F3 800', 'F4', 'F4 RR', 'Brutale 1090', 'Brutale 1090 RR',
    'F4 RC', 'Brutale 800', 'Brutale 800 RR', 'Dragster 800 RR',
    'Turismo Veloce 800', 'Brutale',
  ],
  'Norton':          ['Manx R', 'Manx', 'Atlas', 'Atlas GT', 'Commando 961', 'V4SV', 'V4CR'],
  'Indian':          [
    'Chief', 'Chief Dark Horse', 'Chief Classic', 'Chief Bobber Dark Horse',
    'Springfield', 'Roadmaster', 'Roadmaster PowerPlus Dark Horse',
    'Challenger', 'Pursuit', 'Super Chief Limited', 'Super Scout',
    'Sport Scout', 'Scout Bobber', 'Scout Rogue', 'Scout', 'Scout Sixty',
    'Chief Vintage',
  ],
  'Benelli':         [
    'TRK 502', 'TRK 502X', '502 C', 'Leoncino 500', 'TRK 800',
    'TRK 251', '302R', 'TNT 300', 'TNT 600i', 'TNT 600 GT',
    'TNT 25', 'Leoncino 250', 'TNT 899',
  ],
  'CFMoto':          ['300NK', '650NK', '650MT', '650GT'],
  'Brixton':         ['Crossfire 500X', 'Crossfire 500XC', 'Cromwell 1200', 'Cromwell 1200X'],
  'Husqvarna':       ['Vitpilen 250', 'Svartpilen 250', 'Svartpilen 401', 'Vitpilen 401'],
  'Moto Morini':     ['X-Cape 650', 'X-Cape 650X', 'Seiemmezzo 6½ Street', 'Seiemmezzo 6½ Scrambler'],
  'Zontes':          ['350R', '350X', '350T', '350T ADV', 'GK350'],
  'QJ Motor':        ['SRC 250', 'SRV 300', 'SRK 400', 'SRC 500'],
  'Benda':           ['Dark Flag 500', 'LFC 700', 'LFS 700', 'V302C', 'BD250-3B'],
  'Others':          ['Others'],
};

/* ── Bike condition fields ────────────────────────────────────────────────── */
export const OWNERSHIP_NUMBERS  = ['1', '2', '3', '4', '5'] as const;
export const YES_NO             = ['Yes', 'No'] as const;
export const YES_NO_NA          = ['Yes', 'No', 'N/A'] as const;
export const BATTERY_CONDITIONS = ['Good', 'Need replacement'] as const;
export const TYRE_CONDITIONS    = ['Good', 'Half life', 'Need replacement'] as const;

/* ── Indian states/UTs (33) ──────────────────────────────────────────────── */
export const INDIAN_STATES = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chandigarh',
  'Chhattisgarh', 'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh',
  'Jammu and Kashmir', 'Jharkhand', 'Karnataka', 'Kerala', 'Ladakh',
  'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
  'Nagaland', 'Odisha', 'Puducherry', 'Punjab', 'Rajasthan', 'Sikkim',
  'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
  'West Bengal',
] as const;

/* ── Accessory categories + subcategories ────────────────────────────────── */
export const ACCESSORY_CATEGORIES: { id: string; name: string; subcategories: string[] }[] = [
  {
    id: 'cat_002', name: 'Protection Gear',
    subcategories: ['Helmets', 'Riding Gloves', 'Riding Jackets', 'Riding Pants', 'Riding Boots', 'Other Protectors'],
  },
  {
    id: 'cat_003', name: 'Luggage & Accessories',
    subcategories: [
      'Hard Top Cases', 'Hard Side Cases & Accessories', 'Saddle Bags', 'Soft Luggage',
      'Saddle Stays & Accessories', 'Top Racks & Accessories', 'Tank Bags & Rings',
      'Tail Bags', 'BackPacks', 'Other Luggage accessories',
    ],
  },
  {
    id: 'cat_004', name: 'Lights & Mounts',
    subcategories: ['Aux Lights', 'Clamps & Mounts', 'Wiring Harness', 'Phone Mounts'],
  },
  {
    id: 'cat_005', name: 'Electronic Accessories',
    subcategories: [
      'Communication/Intercom Devices', 'Charging Accessories', 'Dash cams',
      'Autoplay Devices', 'TPMS', 'Other Electronic Accessories',
    ],
  },
  {
    id: 'cat_006', name: 'Universal Bike Accessories',
    subcategories: [
      'Exhaust Systems', 'Crash Guards', 'Radiator Guards',
      'Windscreens & Extenders', 'Side Stand Extenders',
      'Filters, Oil & Lubricants', 'Other Bike Accessories',
    ],
  },
  { id: 'cat_007', name: 'Other Products', subcategories: [] },
];

export const PRODUCT_CONDITIONS = ['New', 'Openbox', 'Used', 'Unused', 'Good', 'Fair', 'Poor'] as const;

/* ── Service categories ───────────────────────────────────────────────────── */
export const SERVICE_CATEGORIES = [
  'Find Mechanic', 'Bike Rentals', 'Track day', 'Training day',
  'Accessory Store', 'Tyre Shops', 'Towing Service',
] as const;

export type ServiceCategory = typeof SERVICE_CATEGORIES[number];

/* Track/Training day specific */
export const RIDER_SKILL_LEVELS = ['All', 'Beginner', 'Novice', 'Intermediate', 'Expert'] as const;
export const BIKE_PROVISION     = ['Self', 'Organizer'] as const;

/* Towing specific */
export const TOWING_SERVICE_TYPES = [
  'Flatbed Tow Truck', 'Hydraulic Lift Tow Truck', 'Pickup Truck',
  'Motorcycle Trailer', 'Wheel Clamp Towing', 'Others',
] as const;
export const SERVICE_COVERAGE_AREAS = ['City', 'Highway', 'District'] as const;

/* ── Month/Year helpers ───────────────────────────────────────────────────── */
export const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
] as const;

export function yearOptions(fromYear = 1990, toYear = new Date().getFullYear()): { value: string; label: string }[] {
  const years = [];
  for (let y = toYear; y >= fromYear; y--) {
    years.push({ value: String(y), label: String(y) });
  }
  return years;
}

export function toSelectOptions(list: readonly string[]): { value: string; label: string }[] {
  return list.map((v) => ({ value: v, label: v }));
}
