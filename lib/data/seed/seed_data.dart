import 'package:mumbai_train_quiz/data/models/product_model.dart';
import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

/// One question before it is turned into a [QuestionModel]. Kept terse so the
/// twenty station sets below read like a list of facts rather than code.
class _Q {
  final String text;
  final List<String> options;
  final int answer;
  final String why;

  const _Q(this.text, this.options, this.answer, this.why);
}

/// The questions the app ships with, so a brand new install is playable with
/// no network and no contributions yet.
///
/// Every question is about something you can actually see, or that sits just
/// behind what you can see, from the window of a Virar → Churchgate slow train.
class SeedData {
  /// Difficulty ramps with the journey — the north end of the line is the warm
  /// up, town is where it gets hard.
  static QuestionDifficulty _difficultyFor(int level) {
    if (level <= 7) return QuestionDifficulty.easy;
    if (level <= 14) return QuestionDifficulty.medium;
    return QuestionDifficulty.hard;
  }

  static List<QuestionModel> questions() {
    final out = <QuestionModel>[];
    _byLevel.forEach((level, set) {
      final station = Stations.byLevel(level);
      for (var i = 0; i < set.length; i++) {
        final q = set[i];
        out.add(QuestionModel(
          // Stable id, so re-seeding overwrites instead of duplicating.
          id: 'seed_${level}_$i',
          level: level,
          stationName: station.name,
          questionText: q.text,
          options: q.options,
          correctOptionIndex: q.answer,
          explanation: q.why,
          difficulty: _difficultyFor(level),
          status: QuestionStatus.approved,
          contributorId: 'system',
          contributorName: 'Journey Guide',
          reviewedBy: 'system',
          isSeed: true,
          synced: true,
        ));
      }
    });
    return out;
  }

  static List<ProductModel> products() => [
        ProductModel(
          id: 'seed_p1',
          name: 'Cutting chai + vada pav',
          description:
              'The platform breakfast. Show your code at the counter any '
              'morning before 11.',
          priceInPoints: 400,
          redeemValueInRupees: 40,
          sellerId: 'seed_s1',
          sellerName: 'Anand Snacks, Dadar West',
          category: 'Food',
          stock: 50,
        ),
        ProductModel(
          id: 'seed_p2',
          name: '₹100 off a monthly season ticket',
          description:
              'Discount voucher towards your next first or second class '
              'season pass.',
          priceInPoints: 1200,
          redeemValueInRupees: 100,
          sellerId: 'seed_s2',
          sellerName: 'Local Commute Co.',
          category: 'Travel',
          stock: 25,
        ),
        ProductModel(
          id: 'seed_p3',
          name: 'Filter coffee at Churchgate',
          description: 'One South Indian filter coffee, any day of the week.',
          priceInPoints: 350,
          redeemValueInRupees: 35,
          sellerId: 'seed_s3',
          sellerName: 'Madras Cafe, Churchgate',
          category: 'Food',
          stock: 60,
        ),
        ProductModel(
          id: 'seed_p4',
          name: 'Mumbai local line poster',
          description:
              'A3 print of the Western, Central and Harbour lines, collected '
              'from the store.',
          priceInPoints: 2000,
          redeemValueInRupees: 250,
          sellerId: 'seed_s4',
          sellerName: 'Kitab Khana Prints',
          category: 'Merchandise',
          stock: 15,
        ),
        ProductModel(
          id: 'seed_p5',
          name: 'Sanjay Gandhi National Park day pass',
          description:
              'Entry for one adult, including the Kanheri Caves trail at '
              'Borivali.',
          priceInPoints: 900,
          redeemValueInRupees: 90,
          sellerId: 'seed_s5',
          sellerName: 'Borivali Trails',
          category: 'Experience',
          stock: 30,
        ),
        ProductModel(
          id: 'seed_p6',
          name: 'Bandra heritage walk',
          description:
              'Two hour guided walk — the station building, Bandstand and '
              'Castella de Aguada.',
          priceInPoints: 3500,
          redeemValueInRupees: 400,
          sellerId: 'seed_s6',
          sellerName: 'Khotachiwadi Walks',
          category: 'Experience',
          stock: 10,
        ),
        ProductModel(
          id: 'seed_p7',
          name: 'Recharge voucher worth ₹50',
          description: 'Mobile recharge code, delivered to your profile.',
          priceInPoints: 600,
          redeemValueInRupees: 50,
          sellerId: 'seed_s7',
          sellerName: 'Sopara Mobile Shop',
          category: 'Utility',
          stock: 100,
        ),
        ProductModel(
          id: 'seed_p8',
          name: 'Thali at Mumbai Central',
          description:
              'Unlimited veg thali, valid on weekdays between 12 and 4.',
          priceInPoints: 2500,
          redeemValueInRupees: 280,
          sellerId: 'seed_s8',
          sellerName: 'Gujarat Bhojanalaya',
          category: 'Food',
          stock: 20,
        ),
      ];

  // ── The journey ────────────────────────────────────────────────────────

  static const Map<int, List<_Q>> _byLevel = {
    1: [
      _Q(
        'Virar is the northern terminus of which Mumbai suburban line?',
        ['Western Line', 'Central Line', 'Harbour Line', 'Trans-Harbour Line'],
        0,
        'Every Virar train you board is heading down the Western Line towards '
            'Churchgate.',
      ),
      _Q(
        'The hill east of Virar, topped by a temple reached by a long flight '
            'of steps, is known as?',
        ['Jivdani', 'Kanheri', 'Gilbert Hill', 'Malabar Hill'],
        0,
        'Jivdani Devi temple sits above Virar and is visible from the '
            'platforms on a clear day.',
      ),
      _Q(
        'The shallow rectangular pans of water on the way out of Virar are '
            'used to produce what?',
        ['Salt', 'Prawns', 'Rice', 'Bricks'],
        0,
        'Seawater is let into the pans and left to evaporate, leaving salt '
            'behind.',
      ),
      _Q(
        'Which beach lies west of Virar, close enough for a share auto from '
            'the station?',
        ['Arnala', 'Juhu', 'Aksa', 'Gorai'],
        0,
        'Arnala, with its sea fort on an island just offshore.',
      ),
      _Q(
        'What does the station code VR on the platform board stand for?',
        ['Virar', 'Vasai Road', 'Vile Parle', 'Vikhroli'],
        0,
        'Vasai Road is BSR and Vile Parle is VLP — VR is Virar itself.',
      ),
    ],
    2: [
      _Q(
        'Nallasopara takes its name from which ancient port town?',
        ['Sopara', 'Salsette', 'Mahim', 'Kalyan'],
        0,
        'Sopara, or Shurparaka, was a major trading port centuries before '
            'Bombay existed.',
      ),
      _Q(
        'A rock edict of which emperor was found at Sopara?',
        ['Ashoka', 'Akbar', 'Kanishka', 'Harsha'],
        0,
        'The Ashokan edict found here is one of the oldest written records in '
            'the region.',
      ),
      _Q(
        'What was Sopara in ancient times?',
        ['A seaport', 'A hill fort', 'A mint', 'A monastery only'],
        0,
        'It traded with Mesopotamia, Arabia and the Mediterranean.',
      ),
      _Q(
        'Nallasopara sits between Virar and which station?',
        ['Vasai Road', 'Bhayandar', 'Naigaon', 'Dahisar'],
        0,
        'Going south the order is Virar, Nallasopara, Vasai Road.',
      ),
      _Q(
        'Which railway zone runs the trains passing through Nallasopara?',
        ['Western Railway', 'Central Railway', 'Konkan Railway', 'South East'],
        0,
        'The whole Virar–Churchgate corridor is Western Railway.',
      ),
    ],
    3: [
      _Q(
        'Vasai Fort, a short ride west of the station, was built by which '
            'colonial power?',
        ['The Portuguese', 'The British', 'The Dutch', 'The French'],
        0,
        'The Portuguese held it until the Marathas took it in 1739.',
      ),
      _Q(
        'The station code BSR comes from which older name for Vasai?',
        ['Bassein', 'Basra', 'Bandora', 'Bhiwandi'],
        0,
        'The British called the town Bassein, so the code stuck as BSR.',
      ),
      _Q(
        'Vasai Road is a junction — the line branching east from here heads '
            'towards which town?',
        ['Diva', 'Karjat', 'Kasara', 'Roha'],
        0,
        'The Vasai Road–Diva link carries trains across to the Central Line.',
      ),
      _Q(
        'Which fruit is the Vasai belt best known for growing?',
        ['Bananas', 'Apples', 'Oranges', 'Grapes'],
        0,
        'Banana plantations still line the road once you leave the tracks.',
      ),
      _Q(
        'Which Maratha general captured Vasai Fort in 1739?',
        ['Chimaji Appa', 'Tanaji Malusare', 'Bajirao II', 'Santaji Ghorpade'],
        0,
        'Chimaji Appa, younger brother of Bajirao I, led the siege.',
      ),
    ],
    4: [
      _Q(
        'The tall pink birds that appear in the creeks near Naigaon in winter '
            'are?',
        ['Flamingos', 'Storks', 'Pelicans', 'Cranes'],
        0,
        'Thousands of flamingos use the creeks and pans around Mumbai as a '
            'winter feeding ground.',
      ),
      _Q(
        'Which months are the best for spotting them from the train?',
        [
          'November to March',
          'June to August',
          'April to May',
          'All year round'
        ],
        0,
        'They arrive after the monsoon and leave before the heat peaks.',
      ),
      _Q(
        'The dense shrubby trees growing right at the water line are?',
        ['Mangroves', 'Banyans', 'Palms', 'Bamboo'],
        0,
        'Mangroves are the only trees that tolerate salt water twice a day.',
      ),
      _Q(
        'What do those mangroves do for the coast?',
        [
          'Slow erosion and flooding',
          'Produce salt',
          'Purify drinking water',
          'Nothing much'
        ],
        0,
        'They break the force of tides and storm surges and hold the mud '
            'together.',
      ),
      _Q(
        'Naigaon lies between Vasai Road and which station?',
        ['Bhayandar', 'Mira Road', 'Nallasopara', 'Borivali'],
        0,
        'Bhayandar is next, across the creek.',
      ),
    ],
    5: [
      _Q(
        'The long bridge just north of Bhayandar carries the line across '
            'which creek?',
        ['Vasai Creek', 'Thane Creek', 'Mahim Creek', 'Manori Creek'],
        0,
        'Vasai Creek is the mouth of the Ulhas river, and the crossing is one '
            'of the longest on the line.',
      ),
      _Q(
        'The white heaps stacked beside the tracks at Bhayandar are?',
        ['Salt', 'Cement', 'Lime', 'Sand'],
        0,
        'Bhayandar has been a salt town far longer than it has been a suburb.',
      ),
      _Q(
        'How is that salt made?',
        [
          'Seawater is evaporated',
          'It is mined underground',
          'It is imported',
          'It is boiled with fuel'
        ],
        0,
        'Tidal water is trapped in pans and the sun does the rest.',
      ),
      _Q(
        'Which coastal village lies west of Bhayandar?',
        ['Uttan', 'Madh', 'Kihim', 'Alibaug'],
        0,
        'Uttan is a fishing village on the coast beyond the salt pans.',
      ),
      _Q(
        'Bhayandar and Mira Road together form which municipal corporation?',
        ['Mira-Bhayandar', 'Vasai-Virar', 'Thane', 'Navi Mumbai'],
        0,
        'They are governed together, separately from Greater Mumbai.',
      ),
    ],
    6: [
      _Q(
        'Mira Road grew mainly as what kind of place?',
        [
          'A planned residential township',
          'An industrial estate',
          'A port',
          'A hill station'
        ],
        0,
        'It was laid out as affordable housing for people working further '
            'down the line.',
      ),
      _Q(
        'Mira Road falls in which district?',
        ['Thane', 'Palghar', 'Raigad', 'Mumbai Suburban'],
        0,
        'The Mumbai district boundary is still a few stations south.',
      ),
      _Q(
        'Before the towers went up, most of this land was?',
        ['Salt pans and marsh', 'Forest', 'Farmland orchards', 'Quarries'],
        0,
        'You can still see the untouched patches from the window.',
      ),
      _Q(
        'Mira Road sits between Bhayandar and which station?',
        ['Dahisar', 'Borivali', 'Naigaon', 'Kandivali'],
        0,
        'Dahisar is next, and it is where Mumbai proper begins.',
      ),
      _Q(
        'Which state are you travelling through on this entire journey?',
        ['Maharashtra', 'Gujarat', 'Goa', 'Karnataka'],
        0,
        'Virar to Churchgate never leaves Maharashtra.',
      ),
    ],
    7: [
      _Q(
        'Dahisar is the first station inside the limits of which city?',
        ['Greater Mumbai', 'Thane', 'Navi Mumbai', 'Vasai-Virar'],
        0,
        'Cross the Dahisar river and you are officially in Mumbai.',
      ),
      _Q(
        'The Dahisar river rises inside which protected area?',
        [
          'Sanjay Gandhi National Park',
          'Tungareshwar',
          'Karnala',
          'Borivali Botanical Garden'
        ],
        0,
        'It starts at Tulsi lake inside the park and runs west to the sea.',
      ),
      _Q(
        'The Dahisar check naka was historically set up to collect what?',
        ['Octroi', 'Train fares', 'Toll on pedestrians', 'Customs duty on gold'],
        0,
        'Goods entering the city were taxed here until octroi was abolished.',
      ),
      _Q(
        'Which major highway begins its Mumbai run at Dahisar?',
        [
          'Western Express Highway',
          'Eastern Express Highway',
          'Sion-Panvel Highway',
          'Link Road'
        ],
        0,
        'The WEH runs from Dahisar all the way down to Bandra.',
      ),
      _Q(
        'Dahisar marks the boundary between Mumbai and which district?',
        ['Thane', 'Palghar', 'Pune', 'Raigad'],
        0,
        'Mira-Bhayandar on the far side belongs to Thane district.',
      ),
    ],
    8: [
      _Q(
        'Borivali is the usual gateway to which protected forest?',
        [
          'Sanjay Gandhi National Park',
          'Tungareshwar',
          'Aarey Colony',
          'Karnala Bird Sanctuary'
        ],
        0,
        'One of the few national parks that sits inside a major city.',
      ),
      _Q(
        'Which ancient Buddhist caves are cut into the rock inside that park?',
        ['Kanheri', 'Ajanta', 'Elephanta', 'Karla'],
        0,
        'Over a hundred cave excavations, carved from the 1st century CE '
            'onwards.',
      ),
      _Q(
        'Those caves are cut into which rock?',
        ['Basalt', 'Granite', 'Sandstone', 'Marble'],
        0,
        'The Deccan basalt that most of this coast is built on.',
      ),
      _Q(
        'Which lake inside the park supplies water to Mumbai?',
        ['Tulsi', 'Powai', 'Upvan', 'Masunda'],
        0,
        'Tulsi and Vihar lakes both sit within the park boundary.',
      ),
      _Q(
        'Besides locals, what else does Borivali station handle?',
        [
          'Long-distance express trains',
          'Only goods trains',
          'Metro trains',
          'Monorail'
        ],
        0,
        'Several outstation trains stop or start at Borivali.',
      ),
    ],
    9: [
      _Q(
        'Which small river runs past Kandivali on its way to the sea?',
        ['Poisar', 'Mithi', 'Oshiwara', 'Ulhas'],
        0,
        'The Poisar is one of four rivers that drain the park into the '
            'Arabian Sea.',
      ),
      _Q(
        'Like the Dahisar river, the Poisar originates in?',
        [
          'Sanjay Gandhi National Park',
          'Powai Lake',
          'Aarey Colony',
          'Vihar Lake'
        ],
        0,
        'Four rivers — Dahisar, Poisar, Oshiwara and Mithi — start in the same '
            'hills.',
      ),
      _Q(
        'Charkop, west of Kandivali, is known for its?',
        [
          'Mangrove belt',
          'Race course',
          'Film studios',
          'Ancient caves'
        ],
        0,
        'A long strip of mangroves survives between the colony and the creek.',
      ),
      _Q(
        'Thakur Village is a neighbourhood of which suburb?',
        ['Kandivali', 'Malad', 'Goregaon', 'Borivali'],
        0,
        'It sits on the east side of Kandivali.',
      ),
      _Q(
        'Kandivali lies between Borivali and which station?',
        ['Malad', 'Goregaon', 'Dahisar', 'Andheri'],
        0,
        'Malad is next, heading south.',
      ),
    ],
    10: [
      _Q(
        'Which large business park sits west of Malad station?',
        ['Mindspace', 'BKC', 'SEEPZ', 'Nariman Point'],
        0,
        'Mindspace turned Malad West into an IT and back-office hub.',
      ),
      _Q(
        'Which mall stands next to it?',
        ['Inorbit', 'Phoenix', 'Palladium', 'Atria'],
        0,
        'Inorbit Malad was among the first big malls in the suburbs.',
      ),
      _Q(
        'Malad Creek separates the mainland from which island?',
        ['Madh', 'Elephanta', 'Butcher', 'Salsette'],
        0,
        'Madh Island lies across the creek, reached by ferry or a long road '
            'loop.',
      ),
      _Q(
        'Which jetty west of Malad runs ferries across to Manori?',
        ['Marve', 'Bhaucha Dhakka', 'Gateway', 'Versova'],
        0,
        'The Marve–Manori ferry is a five minute crossing.',
      ),
      _Q(
        'A yellow building stone used across old Bombay is named after which '
            'of these places?',
        ['Malad', 'Bandra', 'Kurla', 'Thane'],
        0,
        'Malad stone, quarried here, faces many of the city\'s Gothic '
            'buildings.',
      ),
    ],
    11: [
      _Q(
        'Film City, where much of Hindi cinema is shot, is in which suburb?',
        ['Goregaon', 'Andheri', 'Malad', 'Versova'],
        0,
        'It backs onto the national park on the east side of Goregaon.',
      ),
      _Q(
        'What is Film City officially called?',
        [
          'Dadasaheb Phalke Chitranagari',
          'Raj Kapoor Studios',
          'Maharashtra Film Board',
          'Mehboob Studio'
        ],
        0,
        'Named for the father of Indian cinema.',
      ),
      _Q(
        'Aarey Colony was originally set up for what?',
        ['Dairy farming', 'Film shoots', 'Housing', 'A power station'],
        0,
        'It began in 1949 as a milk colony supplying the city.',
      ),
      _Q(
        'Aarey is often described as Mumbai\'s?',
        ['Green lung', 'Gold market', 'Fish market', 'Dockyard'],
        0,
        'Its forest cover is one of the last large green spaces in the '
            'suburbs.',
      ),
      _Q(
        'Which large exhibition centre is at Goregaon?',
        ['NESCO', 'BKC MMRDA Grounds', 'World Trade Centre', 'Vashi Expo'],
        0,
        'The Bombay Exhibition Centre at NESCO hosts most of the city\'s big '
            'trade fairs.',
      ),
    ],
    12: [
      _Q(
        'Which other suburban line terminates at Andheri?',
        ['Harbour Line', 'Central Line', 'Trans-Harbour', 'Vasai-Diva'],
        0,
        'Harbour Line trains from CSMT run up to Andheri via Bandra.',
      ),
      _Q(
        'The elevated Metro line crossing overhead at Andheri runs between '
            'Versova and?',
        ['Ghatkopar', 'Dahisar', 'Thane', 'Mankhurd'],
        0,
        'Metro Line 1, the city\'s first, opened in 2014.',
      ),
      _Q(
        'Gilbert Hill in Andheri West is a rare example of what?',
        [
          'A monolithic basalt column',
          'A limestone cave',
          'A sand dune',
          'A coral reef'
        ],
        0,
        'A sheer 60 metre column of volcanic rock, left standing in the middle '
            'of a suburb.',
      ),
      _Q(
        'What does SEEPZ in Andheri East stand for?',
        [
          'Santacruz Electronics Export Processing Zone',
          'Suburban Export Enterprise Park Zone',
          'Special Economic Export Port Zone',
          'Sahar Electronics Export Park Zone'
        ],
        0,
        'An export zone for electronics and, later, gems and jewellery.',
      ),
      _Q(
        'Which airport is closest to Andheri?',
        [
          'Chhatrapati Shivaji Maharaj International',
          'Juhu Aerodrome',
          'Navi Mumbai International',
          'Kalyan Airstrip'
        ],
        0,
        'Both terminals sit just east of the line here.',
      ),
    ],
    13: [
      _Q(
        'Which well known food brand takes its name from Vile Parle?',
        ['Parle', 'Amul', 'Britannia', 'Haldiram'],
        0,
        'Parle started as a factory in Vile Parle in 1929.',
      ),
      _Q(
        'The aircraft passing low over the tracks here are using which '
            'airport?',
        [
          'Chhatrapati Shivaji Maharaj International',
          'Juhu Aerodrome',
          'Navi Mumbai International',
          'Pune'
        ],
        0,
        'The main runway approach crosses almost directly over this stretch.',
      ),
      _Q(
        'Juhu Aerodrome, near Vile Parle, holds what distinction?',
        [
          'It was India\'s first airport',
          'It is the largest in Asia',
          'It handles only cargo',
          'It was built in 1990'
        ],
        0,
        'Opened in 1928, long before Santacruz took over civil traffic.',
      ),
      _Q(
        'Mithibai College and NMIMS are in which suburb?',
        ['Vile Parle', 'Andheri', 'Bandra', 'Dadar'],
        0,
        'Both sit a short walk west of the station.',
      ),
      _Q(
        'Vile Parle lies between Andheri and which station?',
        ['Santacruz', 'Khar Road', 'Bandra', 'Jogeshwari'],
        0,
        'Santacruz is next going south.',
      ),
    ],
    14: [
      _Q(
        'Bandra\'s heritage station building dates from which year?',
        ['1888', '1853', '1925', '1960'],
        0,
        'The stone building with its gables is one of the oldest still in '
            'daily use on the line.',
      ),
      _Q(
        'The long sea bridge visible west of Bandra is officially named after?',
        [
          'Rajiv Gandhi',
          'Bal Gangadhar Tilak',
          'Vallabhbhai Patel',
          'Jawaharlal Nehru'
        ],
        0,
        'The Bandra–Worli Sea Link is formally the Rajiv Gandhi Sea Link.',
      ),
      _Q(
        'Castella de Aguada, the fort at Bandra\'s western tip, was built by?',
        ['The Portuguese', 'The British', 'The Marathas', 'The Siddis'],
        0,
        'A Portuguese watchtower guarding the mouth of Mahim Bay.',
      ),
      _Q(
        'Mount Mary Basilica, whose fair draws huge crowds each September, is '
            'in which suburb?',
        ['Bandra', 'Vasai', 'Mahim', 'Santacruz'],
        0,
        'The Bandra Fair runs for a week after the feast of the Nativity.',
      ),
      _Q(
        'The tracks just south of Bandra cross which creek?',
        ['Mahim Creek', 'Vasai Creek', 'Thane Creek', 'Malad Creek'],
        0,
        'Mahim Creek is where the Mithi river meets the sea.',
      ),
    ],
    15: [
      _Q(
        'Dadar is the main interchange between the Western Line and which '
            'other line?',
        ['Central Line', 'Harbour Line', 'Metro Line 1', 'Monorail'],
        0,
        'Two stations, one name, and a very short walk between them.',
      ),
      _Q(
        'Dadar\'s famous early morning market sells what?',
        ['Flowers', 'Fish', 'Books', 'Electronics'],
        0,
        'The flower market beside the bridge is busiest before sunrise.',
      ),
      _Q(
        'Shivaji Park at Dadar is known as the nursery of which sport?',
        ['Cricket', 'Football', 'Kabaddi', 'Hockey'],
        0,
        'Generations of Indian test cricketers learned the game on its pitches.',
      ),
      _Q(
        'Chaitya Bhoomi at Dadar is the memorial of?',
        [
          'Dr B. R. Ambedkar',
          'Lokmanya Tilak',
          'Sane Guruji',
          'Jyotirao Phule'
        ],
        0,
        'Lakhs of people gather here every 6 December.',
      ),
      _Q(
        'The Kabutarkhana landmark at Dadar is a place where people feed?',
        ['Pigeons', 'Stray dogs', 'Crows', 'Fish'],
        0,
        'A raised stone platform surrounded by pigeons at all hours.',
      ),
    ],
    16: [
      _Q(
        'The glass towers around Lower Parel stand on the sites of former?',
        ['Textile mills', 'Docks', 'Railway yards', 'Salt pans'],
        0,
        'A few chimneys still stand between the new buildings.',
      ),
      _Q(
        'The mill district was collectively known as?',
        ['Girangaon', 'Kamathipura', 'Bhuleshwar', 'Khotachiwadi'],
        0,
        'Girangaon — literally the village of mills — housed the workers too.',
      ),
      _Q(
        'Phoenix Mills was redeveloped into what?',
        ['A shopping mall', 'A hospital', 'A university', 'A bus depot'],
        0,
        'High Street Phoenix was one of the first mill-to-mall conversions.',
      ),
      _Q(
        'Who led the great Bombay textile strike of 1982?',
        ['Datta Samant', 'George Fernandes', 'S. A. Dange', 'Bal Thackeray'],
        0,
        'The strike lasted over a year and effectively ended the mill industry.',
      ),
      _Q(
        'Kamala Mills today is best known for?',
        [
          'Offices and restaurants',
          'Weaving cloth',
          'A cricket ground',
          'A ferry terminal'
        ],
        0,
        'The compound is now media offices and nightlife.',
      ),
    ],
    17: [
      _Q(
        'The rows of open concrete pens visible from Mahalaxmi station are?',
        ['An open-air laundry', 'Fish drying yards', 'A market', 'Cattle sheds'],
        0,
        'Mahalaxmi Dhobi Ghat, where the city\'s washing has been done for over '
            'a century.',
      ),
      _Q(
        'That laundry holds a Guinness record for?',
        [
          'Most people hand-washing at one location',
          'The largest washing machine',
          'The oldest building',
          'The longest clothesline'
        ],
        0,
        'Hundreds of dhobis work the stone flogging pens at once.',
      ),
      _Q(
        'The large green oval east of the station is used for?',
        ['Horse racing', 'Cricket', 'Football', 'Golf'],
        0,
        'Mahalaxmi Racecourse has been running since 1883.',
      ),
      _Q(
        'The goddess Mahalaxmi, whose temple gives the station its name, is '
            'associated with?',
        ['Wealth', 'Learning', 'War', 'The monsoon'],
        0,
        'The temple sits on the seafront just west of here.',
      ),
      _Q(
        'Haji Ali Dargah, out in the water nearby, is reached by?',
        ['A causeway', 'A ferry', 'A bridge for cars', 'A cable car'],
        0,
        'The walkway floods at high tide, so the shrine is cut off twice a '
            'day.',
      ),
    ],
    18: [
      _Q(
        'The station code BCT stands for?',
        ['Bombay Central', 'Bombay City Terminus', 'Byculla Central', 'Borivali Central'],
        0,
        'The code survives even though the city was renamed.',
      ),
      _Q(
        'Mumbai Central is the main terminus for which railway\'s '
            'long-distance trains?',
        ['Western Railway', 'Central Railway', 'Konkan Railway', 'Northern'],
        0,
        'Trains to Gujarat, Rajasthan and Delhi start from its far platforms.',
      ),
      _Q(
        'The Mumbai Rajdhani Express, introduced in 1972, starts from here. '
            'Where does it run to?',
        ['New Delhi', 'Howrah', 'Chennai', 'Bengaluru'],
        0,
        'It was the second Rajdhani in the country, after Howrah.',
      ),
      _Q(
        'The terminus building was designed by which architect?',
        ['Claude Batley', 'F. W. Stevens', 'George Wittet', 'Charles Correa'],
        0,
        'Batley\'s terminus opened in 1930, well after the Victorian Gothic '
            'era.',
      ),
      _Q(
        'Mumbai Central terminus has been renamed after which 19th century '
            'philanthropist?',
        [
          'Nana Shankarseth',
          'Jamsetjee Jejeebhoy',
          'Jagannath Sunkersett Jr',
          'Premchand Roychand'
        ],
        0,
        'Shankarseth was a founder of the first railway company in India.',
      ),
    ],
    19: [
      _Q(
        'Which cricket stadium stands between Marine Lines and the sea?',
        ['Wankhede', 'Brabourne', 'Eden Gardens', 'Chinnaswamy'],
        0,
        'You can see the floodlights and part of the stand from the train.',
      ),
      _Q(
        'India won which final at that ground in 2011?',
        [
          'The ICC Cricket World Cup',
          'The Champions Trophy',
          'The Asia Cup',
          'The T20 World Cup'
        ],
        0,
        'The first time a host nation won the World Cup final at home.',
      ),
      _Q(
        'The curve of streetlights along the bay at night is nicknamed?',
        [
          'The Queen\'s Necklace',
          'The Golden Mile',
          'The Silver Line',
          'The Crown'
        ],
        0,
        'Seen from Malabar Hill, Marine Drive looks like a string of pearls.',
      ),
      _Q(
        'Marine Drive is officially named after?',
        [
          'Netaji Subhash Chandra Bose',
          'Mahatma Gandhi',
          'Rajiv Gandhi',
          'Sardar Patel'
        ],
        0,
        'Its formal name is Netaji Subhash Chandra Bose Road.',
      ),
      _Q(
        'The large open grounds beside the tracks here are called?',
        ['Maidans', 'Chowks', 'Ghats', 'Wadis'],
        0,
        'Cross Maidan, Azad Maidan and the Oval — the city\'s cricket '
            'nurseries.',
      ),
    ],
    20: [
      _Q(
        'Churchgate is named after a gate of what?',
        [
          'The old Bombay Fort wall',
          'A temple complex',
          'A dockyard',
          'A cemetery'
        ],
        0,
        'The gate faced the church, and the walls came down in the 1860s.',
      ),
      _Q(
        'Which church did that gate lead to?',
        [
          'St Thomas Cathedral',
          'Mount Mary Basilica',
          'Afghan Church',
          'St Michael\'s'
        ],
        0,
        'St Thomas Cathedral still stands near Horniman Circle.',
      ),
      _Q(
        'Eros Cinema, opposite the station, is built in which style?',
        ['Art Deco', 'Victorian Gothic', 'Indo-Saracenic', 'Brutalist'],
        0,
        'Its stepped cream and red facade is a landmark of 1930s Bombay.',
      ),
      _Q(
        'The Oval Maidan is flanked by Art Deco buildings on one side and '
            'what on the other?',
        ['Victorian Gothic', 'Mughal', 'Portuguese Baroque', 'Modernist'],
        0,
        'That face-off across the maidan is a UNESCO World Heritage site.',
      ),
      _Q(
        'Who famously arrives at Churchgate every late morning carrying '
            'stacked tins?',
        ['Dabbawalas', 'Fisherfolk', 'Flower sellers', 'Newspaper vendors'],
        0,
        'Around 5,000 dabbawalas move roughly two lakh lunchboxes a day.',
      ),
    ],
  };
}
