import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/game.dart';

/// Local data source for the game catalog and per-user "My List" storage.
///
/// The catalog is sample data compiled from publicly available information
/// (such as Wikipedia) for titles, descriptions, genres, release years,
/// developers, platforms, classifications, and cover image URLs hosted on
/// reliable public sources (primarily Wikimedia). Ratings are omitted (null)
/// to avoid inventing review scores. If a cover image cannot be loaded by the
/// UI, a fallback cover is displayed.
class GamesLocalDataSource {
  GamesLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const List<Game> _sampleGames = <Game>[
    // --- Existing catalog (updated) ---
    Game(
      id: 'elden-ring',
      title: 'Elden Ring',
      description:
          'An action role-playing game set in the Lands Between where players '
          'explore a vast world and battle formidable foes on a quest to '
          'become Elden Lord.',
      genres: <String>['Action', 'RPG', 'Open World', 'Soulslike'],
      releaseYear: '2022',
      developer: 'FromSoftware',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/elden-ring.jpg',
    ),
    Game(
      id: 'stardew-valley',
      title: 'Stardew Valley',
      description:
          'A farming simulation role-playing game in which players restore a '
          'farm, grow crops, raise animals, and build relationships in Pelican '
          'Town.',
      genres: <String>['Simulation', 'RPG', 'Indie'],
      releaseYear: '2016',
      developer: 'ConcernedApe',
      platforms: <String>[
        'PC',
        'Mobile',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/stardew-valley.jpg',
    ),
    Game(
      id: 'hades',
      title: 'Hades',
      description:
          'A roguelike action game in which Zagreus attempts to escape the '
          'Underworld with the help of Olympian gods and powerful boons.',
      genres: <String>['Action', 'RPG', 'Indie'],
      releaseYear: '2020',
      developer: 'Supergiant Games',
      platforms: <String>[
        'PC',
        'Nintendo Switch',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/hades.jpg',
    ),
    Game(
      id: 'god-of-war-2018',
      title: 'God of War',
      description:
          'An action-adventure game following Kratos and his son Atreus on a '
          'journey through realms inspired by Norse mythology.',
      genres: <String>['Action', 'Adventure'],
      releaseYear: '2018',
      developer: 'Santa Monica Studio',
      platforms: <String>['PlayStation 4', 'PC'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/god-of-war-2018.jpg',
    ),
    Game(
      id: 'witcher-3',
      title: 'The Witcher 3: Wild Hunt',
      description:
          'An open-world action RPG following monster hunter Geralt of Rivia '
          'as he searches for Ciri while confronting the Wild Hunt.',
      genres: <String>['Action', 'RPG', 'Open World'],
      releaseYear: '2015',
      developer: 'CD Projekt Red',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/witcher-3.jpg',
    ),
    Game(
      id: 'hollow-knight',
      title: 'Hollow Knight',
      description:
          'A 2D Metroidvania action-adventure set in the ruined insect kingdom '
          'of Hallownest, focused on exploration and challenging combat.',
      genres: <String>['Action', 'Adventure', 'Platformer', 'Indie'],
      releaseYear: '2017',
      developer: 'Team Cherry',
      platforms: <String>[
        'PC',
        'Nintendo Switch',
        'PlayStation 4',
        'Xbox One',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/hollow-knight.jpg',
    ),
    Game(
      id: 'gta-v',
      title: 'Grand Theft Auto V',
      description:
          'An open-world action-adventure game set in the fictional state of '
          'San Andreas, following three criminals involved in heists and other '
          'crimes.',
      genres: <String>['Action', 'Adventure', 'Open World'],
      releaseYear: '2013',
      developer: 'Rockstar North',
      platforms: <String>[
        'PC',
        'PlayStation 3',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox 360',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/gta-v.jpg',
    ),
    Game(
      id: 'celeste',
      title: 'Celeste',
      description:
          'A precision platformer about climbing Celeste Mountain, featuring '
          'challenging levels and a story centered on perseverance.',
      genres: <String>['Platformer', 'Indie', 'Adventure'],
      releaseYear: '2018',
      developer: 'Maddy Makes Games',
      platforms: <String>[
        'PC',
        'Nintendo Switch',
        'PlayStation 4',
        'Xbox One',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/celeste.jpg',
    ),
    Game(
      id: 'red-dead-redemption-2',
      title: 'Red Dead Redemption 2',
      description:
          'An open-world action-adventure set in 1899, following outlaw Arthur '
          'Morgan and the Van der Linde gang across the American frontier.',
      genres: <String>['Action', 'Adventure', 'Open World'],
      releaseYear: '2018',
      developer: 'Rockstar Studios',
      platforms: <String>['PC', 'PlayStation 4', 'Xbox One'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/red-dead-redemption-2.jpg',
    ),

    // --- Additional games (50) ---
    Game(
      id: 'half-life-2',
      title: 'Half-Life 2',
      description:
          'A first-person shooter in which Gordon Freeman joins the resistance '
          'against the alien Combine occupying Earth.',
      genres: <String>['Action', 'Shooter'],
      releaseYear: '2004',
      developer: 'Valve',
      platforms: <String>['PC', 'Xbox', 'PlayStation 3'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/half-life-2.jpg',
    ),
    Game(
      id: 'doom-2016',
      title: 'DOOM',
      description:
          'A fast-paced first-person shooter where the Doom Slayer battles '
          'demonic forces on Mars and in Hell.',
      genres: <String>['Action', 'Shooter', 'Horror'],
      releaseYear: '2016',
      developer: 'id Software',
      platforms: <String>['PC', 'PlayStation 4', 'Xbox One', 'Nintendo Switch'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/doom-2016.jpg',
    ),
    Game(
      id: 'doom-eternal',
      title: 'DOOM Eternal',
      description:
          'A first-person shooter sequel continuing the Doom Slayer\'s campaign '
          'against demonic invasions across Earth and beyond.',
      genres: <String>['Action', 'Shooter'],
      releaseYear: '2020',
      developer: 'id Software',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/doom-eternal.jpg',
    ),
    Game(
      id: 'dark-souls',
      title: 'Dark Souls',
      description:
          'An action role-playing game known for challenging combat and '
          'interconnected world design set in the kingdom of Lordran.',
      genres: <String>['Action', 'RPG', 'Soulslike'],
      releaseYear: '2011',
      developer: 'FromSoftware',
      platforms: <String>['PC', 'PlayStation 3', 'Xbox 360', 'Nintendo Switch'],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/dark-souls.jpg',
    ),
    Game(
      id: 'dark-souls-iii',
      title: 'Dark Souls III',
      description:
          'An action role-playing game featuring demanding combat and dark '
          'fantasy environments as the Ashen One seeks to link the fire.',
      genres: <String>['Action', 'RPG', 'Soulslike'],
      releaseYear: '2016',
      developer: 'FromSoftware',
      platforms: <String>['PC', 'PlayStation 4', 'Xbox One'],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/dark-souls-iii.jpg',
    ),
    Game(
      id: 'sekiro',
      title: 'Sekiro: Shadows Die Twice',
      description:
          'An action-adventure game set in Sengoku-era Japan where a shinobi '
          'uses sword combat and prosthetic tools on a path of revenge.',
      genres: <String>['Action', 'Adventure', 'Soulslike'],
      releaseYear: '2019',
      developer: 'FromSoftware',
      platforms: <String>['PC', 'PlayStation 4', 'Xbox One'],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/sekiro.jpg',
    ),
    Game(
      id: 'skyrim',
      title: 'The Elder Scrolls V: Skyrim',
      description:
          'An open-world action RPG set in Skyrim where the Dragonborn explores '
          'a vast province and confronts the dragon Alduin.',
      genres: <String>['Action', 'RPG', 'Open World'],
      releaseYear: '2011',
      developer: 'Bethesda Game Studios',
      platforms: <String>[
        'PC',
        'PlayStation 3',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox 360',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/skyrim.jpg',
    ),
    Game(
      id: 'oblivion',
      title: 'The Elder Scrolls IV: Oblivion',
      description:
          'An open-world action RPG in which the player helps stop a cult from '
          'opening gates to the realm of Oblivion.',
      genres: <String>['Action', 'RPG', 'Open World'],
      releaseYear: '2006',
      developer: 'Bethesda Game Studios',
      platforms: <String>['PC', 'PlayStation 3', 'Xbox 360'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/oblivion.jpg',
    ),
    Game(
      id: 'baldurs-gate-3',
      title: "Baldur's Gate 3",
      description:
          'A role-playing game based on Dungeons & Dragons where a party seeks '
          'to overcome a mind flayer parasite in the Forgotten Realms.',
      genres: <String>['RPG', 'Adventure', 'Strategy'],
      releaseYear: '2023',
      developer: 'Larian Studios',
      platforms: <String>['PC', 'PlayStation 5', 'Xbox Series X/S'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/baldurs-gate-3.jpg',
    ),
    Game(
      id: 'persona-5-royal',
      title: 'Persona 5 Royal',
      description:
          'A Japanese role-playing game following students who become Phantom '
          'Thieves, balancing daily life with supernatural adventures.',
      genres: <String>['JRPG', 'RPG', 'Adventure'],
      releaseYear: '2019',
      developer: 'Atlus',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
      ],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/persona-5-royal.jpg',
    ),
    Game(
      id: 'final-fantasy-vii-remake',
      title: 'Final Fantasy VII Remake',
      description:
          'An action role-playing game that reimagines the story of Cloud '
          'Strife and Avalanche in the city of Midgar.',
      genres: <String>['JRPG', 'RPG', 'Action'],
      releaseYear: '2020',
      developer: 'Square Enix',
      platforms: <String>['PlayStation 4', 'PlayStation 5', 'PC'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/final-fantasy-vii-remake.jpg',
    ),
    Game(
      id: 'chrono-trigger',
      title: 'Chrono Trigger',
      description:
          'A classic Japanese role-playing game about adventurers who travel '
          'through time to prevent a global catastrophe.',
      genres: <String>['JRPG', 'RPG', 'Adventure'],
      releaseYear: '1995',
      developer: 'Square',
      platforms: <String>['Super Nintendo Entertainment System', 'PC', 'Mobile'],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/chrono-trigger.jpg',
    ),
    Game(
      id: 'resident-evil-2-remake',
      title: 'Resident Evil 2',
      description:
          'A survival horror remake following Leon S. Kennedy and Claire '
          'Redfield as they attempt to escape Raccoon City.',
      genres: <String>['Horror', 'Survival', 'Action'],
      releaseYear: '2019',
      developer: 'Capcom',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/resident-evil-2-remake.jpg',
    ),
    Game(
      id: 'resident-evil-4-remake',
      title: 'Resident Evil 4',
      description:
          'A survival horror remake in which Leon S. Kennedy undertakes a '
          'mission to rescue Ashley Graham in a remote European village.',
      genres: <String>['Horror', 'Survival', 'Action'],
      releaseYear: '2023',
      developer: 'Capcom',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox Series X/S',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/resident-evil-4-remake.jpg',
    ),
    Game(
      id: 'resident-evil-7',
      title: 'Resident Evil 7: Biohazard',
      description:
          'A first-person survival horror game in which Ethan Winters searches '
          'for his missing wife at a derelict plantation.',
      genres: <String>['Horror', 'Survival', 'Action'],
      releaseYear: '2017',
      developer: 'Capcom',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/resident-evil-7.jpg',
    ),
    Game(
      id: 'silent-hill-2',
      title: 'Silent Hill 2',
      description:
          'A psychological survival horror game in which James Sunderland '
          'travels to Silent Hill after receiving a letter from his deceased '
          'wife.',
      genres: <String>['Horror', 'Survival', 'Adventure'],
      releaseYear: '2001',
      developer: 'Konami Computer Entertainment Tokyo',
      platforms: <String>['PlayStation 2', 'Xbox', 'PC'],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/silent-hill-2.jpg',
    ),
    Game(
      id: 'horizon-zero-dawn',
      title: 'Horizon Zero Dawn',
      description:
          'An open-world action RPG in which hunter Aloy explores a world of '
          'robotic creatures to uncover the secrets of her past.',
      genres: <String>['Action', 'RPG', 'Open World'],
      releaseYear: '2017',
      developer: 'Guerrilla Games',
      platforms: <String>['PlayStation 4', 'PC'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/horizon-zero-dawn.jpg',
    ),
    Game(
      id: 'ghost-of-tsushima',
      title: 'Ghost of Tsushima',
      description:
          'An open-world action-adventure set during the first Mongol invasion '
          'of Japan, following samurai Jin Sakai.',
      genres: <String>['Action', 'Adventure', 'Open World'],
      releaseYear: '2020',
      developer: 'Sucker Punch Productions',
      platforms: <String>['PlayStation 4', 'PlayStation 5', 'PC'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/ghost-of-tsushima.jpg',
    ),
    Game(
      id: 'assassins-creed-valhalla',
      title: "Assassin's Creed Valhalla",
      description:
          'An open-world action RPG following Viking raider Eivor during '
          'expeditions in England during the ninth century.',
      genres: <String>['Action', 'RPG', 'Open World'],
      releaseYear: '2020',
      developer: 'Ubisoft Montreal',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/assassins-creed-valhalla.jpg',
    ),
    Game(
      id: 'cyberpunk-2077',
      title: 'Cyberpunk 2077',
      description:
          'An open-world action RPG set in Night City, where mercenary V seeks '
          'a way to survive after a high-risk heist.',
      genres: <String>['Action', 'RPG', 'Open World'],
      releaseYear: '2020',
      developer: 'CD Projekt Red',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/cyberpunk-2077.jpg',
    ),
    Game(
      id: 'ori-and-the-will-of-the-wisps',
      title: 'Ori and the Will of the Wisps',
      description:
          'A platform-adventure Metroidvania following Ori on a journey through '
          'the forest of Niwen.',
      genres: <String>['Platformer', 'Adventure', 'Indie'],
      releaseYear: '2020',
      developer: 'Moon Studios',
      platforms: <String>['PC', 'Xbox One', 'Xbox Series X/S', 'Nintendo Switch'],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/ori-and-the-will-of-the-wisps.jpg',
    ),
    Game(
      id: 'cuphead',
      title: 'Cuphead',
      description:
          'A run-and-gun platformer known for boss battles and visuals inspired '
          'by 1930s cartoons.',
      genres: <String>['Platformer', 'Action', 'Indie'],
      releaseYear: '2017',
      developer: 'Studio MDHR',
      platforms: <String>[
        'PC',
        'Xbox One',
        'Nintendo Switch',
        'PlayStation 4',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/cuphead.jpg',
    ),
    Game(
      id: 'dead-cells',
      title: 'Dead Cells',
      description:
          'A roguelike-inspired action-platformer where players explore a '
          'changing castle and battle challenging enemies.',
      genres: <String>['Action', 'Platformer', 'Indie'],
      releaseYear: '2018',
      developer: 'Motion Twin',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
        'Mobile',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/dead-cells.jpg',
    ),
    Game(
      id: 'undertale',
      title: 'Undertale',
      description:
          'A role-playing game in which a child explores the Underground and '
          'can choose how to interact with the monsters encountered.',
      genres: <String>['RPG', 'Indie', 'Adventure'],
      releaseYear: '2015',
      developer: 'Toby Fox',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation Vita',
        'Nintendo Switch',
        'Xbox One',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/undertale.jpg',
    ),
    Game(
      id: 'terraria',
      title: 'Terraria',
      description:
          'A 2D sandbox action-adventure game focused on exploration, building, '
          'crafting, combat, and survival.',
      genres: <String>['Sandbox', 'Survival', 'Adventure', 'Indie'],
      releaseYear: '2011',
      developer: 'Re-Logic',
      platforms: <String>[
        'PC',
        'Mobile',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/terraria.jpg',
    ),
    Game(
      id: 'subnautica',
      title: 'Subnautica',
      description:
          'An open-world survival adventure game set on an alien ocean planet, '
          'where players gather resources and explore underwater.',
      genres: <String>['Survival', 'Adventure', 'Open World', 'Indie'],
      releaseYear: '2018',
      developer: 'Unknown Worlds Entertainment',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/subnautica.jpg',
    ),
    Game(
      id: 'slay-the-spire',
      title: 'Slay the Spire',
      description:
          'A roguelike deck-building game in which players craft a deck and '
          'battle enemies while climbing a spire.',
      genres: <String>['Strategy', 'RPG', 'Indie'],
      releaseYear: '2019',
      developer: 'MegaCrit',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
        'Mobile',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/slay-the-spire.jpg',
    ),
    Game(
      id: 'disco-elysium',
      title: 'Disco Elysium',
      description:
          'A role-playing game focused on dialogue and investigation, following '
          'a detective solving a case in the city of Revachol.',
      genres: <String>['RPG', 'Adventure', 'Indie'],
      releaseYear: '2019',
      developer: 'ZA/UM',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/disco-elysium.jpg',
    ),
    Game(
      id: 'outer-wilds',
      title: 'Outer Wilds',
      description:
          'An open-world exploration game set in a solar system trapped in a '
          'time loop, where players uncover ancient mysteries.',
      genres: <String>['Adventure', 'Open World', 'Indie'],
      releaseYear: '2019',
      developer: 'Mobius Digital',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/outer-wilds.jpg',
    ),
    Game(
      id: 'vampire-survivors',
      title: 'Vampire Survivors',
      description:
          'A time-survival action game where players fight waves of monsters '
          'and collect upgrades to survive as long as possible.',
      genres: <String>['Action', 'Survival', 'Indie'],
      releaseYear: '2022',
      developer: 'Poncle',
      platforms: <String>[
        'PC',
        'Xbox One',
        'Xbox Series X/S',
        'Nintendo Switch',
        'Mobile',
        'PlayStation 4',
        'PlayStation 5',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/vampire-survivors.jpg',
    ),
    Game(
      id: 'limbo',
      title: 'Limbo',
      description:
          'A puzzle-platformer in which a boy searches for his sister through '
          'hazardous, monochrome environments.',
      genres: <String>['Platformer', 'Adventure', 'Indie'],
      releaseYear: '2010',
      developer: 'Playdead',
      platforms: <String>[
        'PC',
        'Mobile',
        'PlayStation 3',
        'PlayStation 4',
        'Xbox 360',
        'Xbox One',
        'Nintendo Switch',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/limbo.jpg',
    ),
    Game(
      id: 'inside',
      title: 'Inside',
      description:
          'A puzzle-platformer adventure following a boy through a dystopian '
          'world filled with dangers and secrets.',
      genres: <String>['Platformer', 'Adventure', 'Indie'],
      releaseYear: '2016',
      developer: 'Playdead',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
        'Mobile',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/inside.jpg',
    ),
    Game(
      id: 'shovel-knight',
      title: 'Shovel Knight',
      description:
          'A 2D side-scrolling platformer starring Shovel Knight on a quest to '
          'defeat the Order of No Quarter.',
      genres: <String>['Platformer', 'Action', 'Indie'],
      releaseYear: '2014',
      developer: 'Yacht Club Games',
      platforms: <String>[
        'PC',
        'PlayStation 3',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
        'Nintendo 3DS',
        'Wii U',
      ],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/shovel-knight.jpg',
    ),
    Game(
      id: 'factorio',
      title: 'Factorio',
      description:
          'A construction and management simulation game about building and '
          'automating factories on an alien planet.',
      genres: <String>['Simulation', 'Strategy', 'Indie'],
      releaseYear: '2020',
      developer: 'Wube Software',
      platforms: <String>['PC', 'Nintendo Switch'],
      classification: 'Indie',
      coverImagePath: 'assets/game_covers/factorio.jpg',
    ),
    Game(
      id: 'cities-skylines',
      title: 'Cities: Skylines',
      description:
          'A city-building simulation game where players design and manage a '
          'city and its public services and infrastructure.',
      genres: <String>['Simulation', 'Strategy'],
      releaseYear: '2015',
      developer: 'Colossal Order',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
      ],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/cities-skylines.jpg',
    ),
    Game(
      id: 'civilization-vi',
      title: "Sid Meier's Civilization VI",
      description:
          'A turn-based strategy game in which players develop a civilization '
          'from ancient times into the modern era.',
      genres: <String>['Strategy', 'Simulation'],
      releaseYear: '2016',
      developer: 'Firaxis Games',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
        'Mobile',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/civilization-vi.jpg',
    ),
    Game(
      id: 'age-of-empires-ii-de',
      title: 'Age of Empires II: Definitive Edition',
      description:
          'A real-time strategy game featuring historical civilizations and '
          'campaigns in an enhanced definitive edition.',
      genres: <String>['Strategy'],
      releaseYear: '2019',
      developer: 'Forgotten Empires',
      platforms: <String>['PC', 'Xbox One', 'Xbox Series X/S'],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/age-of-empires-ii-de.jpg',
    ),
    Game(
      id: 'forza-horizon-5',
      title: 'Forza Horizon 5',
      description:
          'An open-world racing game set in Mexico featuring varied terrain, '
          'events, and a large collection of cars.',
      genres: <String>['Racing', 'Open World'],
      releaseYear: '2021',
      developer: 'Playground Games',
      platforms: <String>['PC', 'Xbox One', 'Xbox Series X/S'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/forza-horizon-5.jpg',
    ),
    Game(
      id: 'a-plague-tale-innocence',
      title: 'A Plague Tale: Innocence',
      description:
          'An action-adventure game following Amicia and Hugo as they survive '
          'war and plague-ridden France.',
      genres: <String>['Action', 'Adventure', 'Horror'],
      releaseYear: '2019',
      developer: 'Asobo Studio',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/a-plague-tale-innocence.jpg',
    ),
    Game(
      id: 'hellblade-senuas-sacrifice',
      title: "Hellblade: Senua's Sacrifice",
      description:
          'An action-adventure game following Senua on a journey through a '
          'mythic underworld inspired by Norse mythology.',
      genres: <String>['Action', 'Adventure'],
      releaseYear: '2017',
      developer: 'Ninja Theory',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'Xbox One',
        'Nintendo Switch',
        'Xbox Series X/S',
      ],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/hellblade-senuas-sacrifice.jpg',
    ),
    Game(
      id: 'control',
      title: 'Control',
      description:
          'An action-adventure game in which Jesse Faden explores the Federal '
          'Bureau of Control and uses supernatural abilities.',
      genres: <String>['Action', 'Adventure'],
      releaseYear: '2019',
      developer: 'Remedy Entertainment',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/control.jpg',
    ),
    Game(
      id: 'lies-of-p',
      title: 'Lies of P',
      description:
          'A soulslike action RPG inspired by Pinocchio, set in a dark city '
          'overrun by hostile puppets.',
      genres: <String>['Action', 'RPG', 'Soulslike'],
      releaseYear: '2023',
      developer: 'Neowiz Games and Round8 Studio',
      platforms: <String>[
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/lies-of-p.jpg',
    ),
    Game(
      id: 'nier-automata',
      title: 'NieR:Automata',
      description:
          'An action role-playing game following androids in a conflict between '
          'machines and android forces on a post-apocalyptic Earth.',
      genres: <String>['Action', 'RPG', 'JRPG'],
      releaseYear: '2017',
      developer: 'PlatinumGames',
      platforms: <String>['PC', 'PlayStation 4', 'Xbox One', 'Nintendo Switch'],
      classification: 'AA',
      coverImagePath: 'assets/game_covers/nier-automata.jpg',
    ),
    Game(
      id: 'monster-hunter-world',
      title: 'Monster Hunter: World',
      description:
          'An action role-playing game where players hunt large monsters and '
          'craft equipment from gathered materials.',
      genres: <String>['Action', 'RPG'],
      releaseYear: '2018',
      developer: 'Capcom',
      platforms: <String>['PC', 'PlayStation 4', 'Xbox One'],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/monster-hunter-world.jpg',
    ),
    Game(
      id: 'monster-hunter-rise',
      title: 'Monster Hunter Rise',
      description:
          'An action role-playing game in which hunters defend Kamura Village '
          'from monsters using fast-paced combat and traversal.',
      genres: <String>['Action', 'RPG'],
      releaseYear: '2021',
      developer: 'Capcom',
      platforms: <String>[
        'Nintendo Switch',
        'PC',
        'PlayStation 4',
        'PlayStation 5',
        'Xbox One',
        'Xbox Series X/S',
      ],
      classification: 'AAA',
      coverImagePath: 'assets/game_covers/monster-hunter-rise.jpg',
    ),
  ];

  /// Returns the local sample game catalog.
  Future<List<Game>> getGames() async {
    return _sampleGames;
  }

  /// Returns the saved game IDs for the given user.
  Future<Set<String>> getMyListGameIds(String userId) async {
    return (_prefs.getStringList(_storageKeyForUser(userId)) ?? <String>[])
        .toSet();
  }

  /// Saves the user's game ID list.
  Future<void> saveMyListGameIds(String userId, Set<String> ids) async {
    await _prefs.setStringList(_storageKeyForUser(userId), ids.toList());
  }

  String _storageKeyForUser(String userId) => 'my_game_list_$userId';
}
