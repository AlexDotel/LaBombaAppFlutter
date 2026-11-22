// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'The Bomb';

  @override
  String get howToPlay => 'HOW TO PLAY';

  @override
  String get tutorialTitle => 'Be ready before\nthe bomb gets you.';

  @override
  String get phoneCenterTitle => 'Phone in the center';

  @override
  String get phoneCenterText => 'Place it where everyone can see and hear it.';

  @override
  String get chooseActivateTitle => 'Choose and activate a category';

  @override
  String get chooseActivateText =>
      'Name valid answers until the bomb explodes.';

  @override
  String get whoStartsTitle => 'Who starts';

  @override
  String get whoStartsText =>
      'The phone owner starts the first round. After that, whoever lost the previous round starts.';

  @override
  String get tutorialDone => 'Got it, let\'s play';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get darkModeTooltip => 'Dark mode';

  @override
  String get lightModeTooltip => 'Light mode';

  @override
  String get homeTitle => 'Name things.\nDon\'t get caught.';

  @override
  String get homeDescription =>
      'Choose a category and give answers without repeating until the bomb explodes.';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get homeFooter => 'NO NAMES · NO PLAYERS · NO TURNS';

  @override
  String get chooseCategoryTitle => 'Choose a category';

  @override
  String get everyonePlays => 'The whole group plays together.';

  @override
  String get chosenCategory => 'CHOSEN CATEGORY';

  @override
  String get quick => 'Quick';

  @override
  String get normal => 'Normal';

  @override
  String get long => 'Long';

  @override
  String explosionRange(int min, int max) {
    return 'The bomb will explode between $min and $max seconds.';
  }

  @override
  String get lightFuse => 'Light the fuse';

  @override
  String get cancelCountdown => 'Cancel countdown';

  @override
  String get previousLoserStarts => 'THE PREVIOUS ROUND\'S\nLOSER STARTS';

  @override
  String get chooseWhoStarts => 'CHOOSE WHO STARTS';

  @override
  String get bombStartsAtZero => 'The bomb will start at zero';

  @override
  String get paused => 'PAUSED';

  @override
  String get tickTock => 'TICK · TOCK · TICK · TOCK';

  @override
  String get changePrompt => 'Change prompt';

  @override
  String get tapToContinue => 'Tap ▶ to continue';

  @override
  String get keepAnswering => 'Keep answering until it explodes';

  @override
  String get boom => 'BOOM!';

  @override
  String get lostRound => 'You lost this round';

  @override
  String anotherFrom(String category) {
    return 'Another from $category';
  }

  @override
  String get changeCategory => 'Change category';

  @override
  String get newPrompt => 'New prompt';

  @override
  String get category => 'Category';

  @override
  String get prompt => 'Prompt';

  @override
  String get promptHint => 'E.g. Things you would take to Mars';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get createCategory => 'Create category';

  @override
  String get name => 'Name';

  @override
  String get icon => 'Icon';

  @override
  String get emojiHelp => 'You can paste any emoji';

  @override
  String get firstPrompt => 'First prompt';

  @override
  String get create => 'Create';

  @override
  String get promptAdded => 'Prompt added';

  @override
  String get newPromptRequired => 'Enter a new prompt';

  @override
  String get categoryCreated => 'Category created';

  @override
  String get categoryReview => 'Check the name and prompt';

  @override
  String get yourContent => 'Your content';

  @override
  String get customizeGame => 'Customize the game';

  @override
  String get localOnly => 'Everything you add is stored only on this phone.';

  @override
  String get addPrompt => 'Add prompt';

  @override
  String get ownCategories => 'YOUR CATEGORIES';

  @override
  String ownPromptCount(int count) {
    return '$count custom prompts';
  }

  @override
  String get noOwnCategories => 'You haven\'t created any yet.';

  @override
  String get ownPrompts => 'ADDED PROMPTS';

  @override
  String get noOwnPrompts => 'You haven\'t added any yet.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String deleteCategoryMessage(String category) {
    return 'The “$category” category and all its prompts will be deleted.';
  }

  @override
  String get deletePromptTitle => 'Delete prompt?';

  @override
  String deletePromptMessage(String prompt) {
    return 'The “$prompt” prompt will no longer appear in the game.';
  }

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get promptDeleted => 'Prompt deleted';

  @override
  String get lastPromptDeleted =>
      'The category was also deleted because it had no prompts left';

  @override
  String get settings => 'Settings';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkDefault => 'Dark mode remains the default';

  @override
  String get categoriesAndPrompts => 'Categories and prompts';

  @override
  String get addLocalContent => 'Add your own content stored on this phone';

  @override
  String get bombSound => 'Bomb sound';

  @override
  String get soundEnabled => 'Continuous ticking and explosion enabled';

  @override
  String get soundDisabled => 'Ticking and explosion disabled';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationEnabled => 'Haptic impact when the bomb explodes';

  @override
  String get vibrationDisabled => 'The bomb won\'t vibrate when it explodes';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get rateAppDescription => 'Share your opinion on Google Play';

  @override
  String get ratePromptTitle => 'Enjoying The Bomb?';

  @override
  String get ratePromptMessage =>
      'Your rating helps us improve the game and reach more players.';

  @override
  String get rateNow => 'Rate now';

  @override
  String get later => 'Maybe later';

  @override
  String get moreGames => 'MORE GAMES';

  @override
  String get playTruthOrDare => 'Play Truth or Dare';

  @override
  String get playImpostor => 'Play Impostor';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Language used by the application';

  @override
  String get languageAutomatic => 'Automatic (device)';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get gameReminders => 'Game reminders';

  @override
  String get remindersEnabled => 'Thursday, Friday and Saturday at 9:10 PM';

  @override
  String get remindersDisabled => 'You won\'t receive reminders to play';

  @override
  String get privacyOptions => 'Privacy options';

  @override
  String get privacyOptionsDescription =>
      'Manage consent and ad personalization';

  @override
  String get lightFuseRandom => 'Light the fuse (Random)';

  @override
  String get orChooseCategory => 'Or choose a category';

  @override
  String get createMine => 'Create mine';

  @override
  String get tapAndPlay => 'Tap & play';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get filterMine => 'Mine';

  @override
  String get noFavoritesYet => 'Tap the star on any category to pin it here.';

  @override
  String get rewards => 'Rewards';

  @override
  String get sparksTooltip => 'Sparks & rewards';

  @override
  String get earnSparksTitle => 'Earn +50 free Sparks';

  @override
  String get earnSparksSubtitle =>
      'Watch a short ad to unlock special packs and bomb skins for free.';

  @override
  String get watchAdEarn => 'Watch ad (+50 ⚡)';

  @override
  String get specialPacks => 'SPECIAL PACKS';

  @override
  String get bombSkins => 'BOMB SKINS';

  @override
  String get unlockWithAd24h => '1 ad (24h)';

  @override
  String unlockWithSparks(int cost) {
    return '$cost ⚡';
  }

  @override
  String get active24h => 'Active 24h';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get equipped => 'Equipped';

  @override
  String get equip => 'Equip';

  @override
  String get freeLabel => 'Free';

  @override
  String get adNotReady =>
      'No ad is ready right now. Try again in a few seconds.';

  @override
  String rewardEarnedSparks(int amount) {
    return '+$amount ⚡ Sparks added!';
  }

  @override
  String packUnlocked24h(String pack) {
    return '“$pack” pack unlocked for 24h';
  }

  @override
  String packUnlockedForever(String pack) {
    return '“$pack” pack unlocked forever';
  }

  @override
  String skinUnlocked(String skin) {
    return '“$skin” skin unlocked and equipped';
  }

  @override
  String get notEnoughSparks =>
      'Not enough Sparks ⚡. Watch an ad above to earn more.';

  @override
  String swapsLeft(int count) {
    return 'Change prompt ($count)';
  }

  @override
  String get watchAdMoreSwaps => 'Watch ad (+3 swaps)';

  @override
  String get swapsRecharged => '+3 prompt swaps unlocked';

  @override
  String get loserDareTitle => 'LOSER\'S DARE';

  @override
  String get anotherDare => 'Reroll';

  @override
  String get roundSparksBonus => '+10 ⚡ for completing the round';

  @override
  String get watchAdBonusSparks => 'Watch ad for +30 ⚡';

  @override
  String get loserDareSetting => 'Loser\'s dare';

  @override
  String get loserDareEnabled => 'Show an optional fun dare when it explodes';

  @override
  String get loserDareDisabled => 'No dares at the end of the round';

  @override
  String get dynamicTension => 'Dynamic tension';

  @override
  String get dynamicTensionEnabled => 'Ticking speeds up near the end';

  @override
  String get dynamicTensionDisabled => 'Steady ticking pace';

  @override
  String get sectionGameAudio => 'GAME & AUDIO';

  @override
  String get sectionAppearance => 'APPEARANCE & LANGUAGE';

  @override
  String get sectionContent => 'CONTENT & PRIVACY';

  @override
  String get skinClassic => 'Classic';

  @override
  String get skinNeon => 'Neon';

  @override
  String get skinDynamite => 'Dynamite';

  @override
  String get skinGold => 'Golden';

  @override
  String packPromptCount(int count) {
    return '$count exclusive prompts';
  }

  @override
  String get createCategoryCost => 'Create category (10 ⚡)';

  @override
  String get needSparksForCategory =>
      'You need 10 ⚡ Sparks to create a category.';

  @override
  String get maxPromptsReached => 'Maximum 10 prompts per custom category.';

  @override
  String ownPromptCountMax(int count) {
    return '$count / 10 prompts';
  }

  @override
  String get addPromptCost => 'Add prompt (5 ⚡)';

  @override
  String get needSparksForPrompt => 'You need 5 ⚡ Sparks to add a prompt.';

  @override
  String get shop => 'Shop';

  @override
  String get bombShopTitle => 'Bomb Shop';

  @override
  String get skinMafioso => 'Don Bomb';

  @override
  String get skinTattoo => 'Tattooed';

  @override
  String get skinCat => 'Kitty';

  @override
  String get skinPirate => 'Pirate';

  @override
  String get skinNinja => 'Ninja';

  @override
  String get skinKing => 'Golden King';

  @override
  String get skinAlien => 'Alien';

  @override
  String get skinPunk => 'Punk Rock';

  @override
  String get skinViking => 'Viking';

  @override
  String get skinPanda => 'Panda';

  @override
  String get skinCyber => 'Cyber Neon';

  @override
  String get skinDevil => 'Little Devil';
}
