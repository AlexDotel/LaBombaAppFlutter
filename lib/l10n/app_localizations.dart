import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'La Bomba'**
  String get appName;

  /// No description provided for @howToPlay.
  ///
  /// In es, this message translates to:
  /// **'CÓMO SE JUEGA'**
  String get howToPlay;

  /// No description provided for @tutorialTitle.
  ///
  /// In es, this message translates to:
  /// **'Que la bomba os\npille preparados.'**
  String get tutorialTitle;

  /// No description provided for @phoneCenterTitle.
  ///
  /// In es, this message translates to:
  /// **'Móvil en el centro'**
  String get phoneCenterTitle;

  /// No description provided for @phoneCenterText.
  ///
  /// In es, this message translates to:
  /// **'Dejadlo donde todos puedan verlo y escucharlo.'**
  String get phoneCenterText;

  /// No description provided for @chooseActivateTitle.
  ///
  /// In es, this message translates to:
  /// **'Elegid y activad una categoría'**
  String get chooseActivateTitle;

  /// No description provided for @chooseActivateText.
  ///
  /// In es, this message translates to:
  /// **'Nombrad respuestas válidas hasta que la bomba explote.'**
  String get chooseActivateText;

  /// No description provided for @whoStartsTitle.
  ///
  /// In es, this message translates to:
  /// **'Quién empieza'**
  String get whoStartsTitle;

  /// No description provided for @whoStartsText.
  ///
  /// In es, this message translates to:
  /// **'La primera ronda empieza el dueño del móvil. Después, empieza quien perdió la ronda anterior.'**
  String get whoStartsText;

  /// No description provided for @tutorialDone.
  ///
  /// In es, this message translates to:
  /// **'Entendido, vamos a jugar'**
  String get tutorialDone;

  /// No description provided for @settingsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTooltip;

  /// No description provided for @darkModeTooltip.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get darkModeTooltip;

  /// No description provided for @lightModeTooltip.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get lightModeTooltip;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'Nombra cosas.\nQue no te pille.'**
  String get homeTitle;

  /// No description provided for @homeDescription.
  ///
  /// In es, this message translates to:
  /// **'Elegid una categoría y decid respuestas sin repetir hasta que la bomba explote.'**
  String get homeDescription;

  /// No description provided for @chooseCategory.
  ///
  /// In es, this message translates to:
  /// **'Elegir categoría'**
  String get chooseCategory;

  /// No description provided for @homeFooter.
  ///
  /// In es, this message translates to:
  /// **'SIN NOMBRES · SIN JUGADORES · SIN TURNOS'**
  String get homeFooter;

  /// No description provided for @chooseCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige una categoría'**
  String get chooseCategoryTitle;

  /// No description provided for @everyonePlays.
  ///
  /// In es, this message translates to:
  /// **'Todo el grupo juega a la vez.'**
  String get everyonePlays;

  /// No description provided for @chosenCategory.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍA ELEGIDA'**
  String get chosenCategory;

  /// No description provided for @quick.
  ///
  /// In es, this message translates to:
  /// **'Rápida'**
  String get quick;

  /// No description provided for @normal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @long.
  ///
  /// In es, this message translates to:
  /// **'Larga'**
  String get long;

  /// No description provided for @explosionRange.
  ///
  /// In es, this message translates to:
  /// **'La explosión ocurrirá entre {min} y {max} segundos.'**
  String explosionRange(int min, int max);

  /// No description provided for @lightFuse.
  ///
  /// In es, this message translates to:
  /// **'Encender la mecha'**
  String get lightFuse;

  /// No description provided for @cancelCountdown.
  ///
  /// In es, this message translates to:
  /// **'Cancelar cuenta atrás'**
  String get cancelCountdown;

  /// No description provided for @previousLoserStarts.
  ///
  /// In es, this message translates to:
  /// **'EMPIEZA QUIEN PERDIÓ\nLA RONDA ANTERIOR'**
  String get previousLoserStarts;

  /// No description provided for @chooseWhoStarts.
  ///
  /// In es, this message translates to:
  /// **'ELEGID QUIÉN EMPIEZA'**
  String get chooseWhoStarts;

  /// No description provided for @bombStartsAtZero.
  ///
  /// In es, this message translates to:
  /// **'La bomba se encenderá al llegar a cero'**
  String get bombStartsAtZero;

  /// No description provided for @paused.
  ///
  /// In es, this message translates to:
  /// **'EN PAUSA'**
  String get paused;

  /// No description provided for @tickTock.
  ///
  /// In es, this message translates to:
  /// **'TIC · TAC · TIC · TAC'**
  String get tickTock;

  /// No description provided for @changePrompt.
  ///
  /// In es, this message translates to:
  /// **'Cambiar consigna'**
  String get changePrompt;

  /// No description provided for @tapToContinue.
  ///
  /// In es, this message translates to:
  /// **'Pulsa ▶ para continuar'**
  String get tapToContinue;

  /// No description provided for @keepAnswering.
  ///
  /// In es, this message translates to:
  /// **'Seguid respondiendo hasta que explote'**
  String get keepAnswering;

  /// No description provided for @boom.
  ///
  /// In es, this message translates to:
  /// **'¡BOOM!'**
  String get boom;

  /// No description provided for @lostRound.
  ///
  /// In es, this message translates to:
  /// **'Has perdido esta ronda'**
  String get lostRound;

  /// No description provided for @anotherFrom.
  ///
  /// In es, this message translates to:
  /// **'Otra de {category}'**
  String anotherFrom(String category);

  /// No description provided for @changeCategory.
  ///
  /// In es, this message translates to:
  /// **'Cambiar categoría'**
  String get changeCategory;

  /// No description provided for @newPrompt.
  ///
  /// In es, this message translates to:
  /// **'Nueva consigna'**
  String get newPrompt;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @prompt.
  ///
  /// In es, this message translates to:
  /// **'Consigna'**
  String get prompt;

  /// No description provided for @promptHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Cosas que llevarías a Marte'**
  String get promptHint;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @createCategory.
  ///
  /// In es, this message translates to:
  /// **'Crear categoría'**
  String get createCategory;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @icon.
  ///
  /// In es, this message translates to:
  /// **'Icono'**
  String get icon;

  /// No description provided for @emojiHelp.
  ///
  /// In es, this message translates to:
  /// **'Puedes pegar cualquier emoji'**
  String get emojiHelp;

  /// No description provided for @firstPrompt.
  ///
  /// In es, this message translates to:
  /// **'Primera consigna'**
  String get firstPrompt;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @promptAdded.
  ///
  /// In es, this message translates to:
  /// **'Consigna añadida'**
  String get promptAdded;

  /// No description provided for @newPromptRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe una consigna nueva'**
  String get newPromptRequired;

  /// No description provided for @categoryCreated.
  ///
  /// In es, this message translates to:
  /// **'Categoría creada'**
  String get categoryCreated;

  /// No description provided for @categoryReview.
  ///
  /// In es, this message translates to:
  /// **'Revisa el nombre y la consigna'**
  String get categoryReview;

  /// No description provided for @yourContent.
  ///
  /// In es, this message translates to:
  /// **'Tu contenido'**
  String get yourContent;

  /// No description provided for @customizeGame.
  ///
  /// In es, this message translates to:
  /// **'Personaliza el juego'**
  String get customizeGame;

  /// No description provided for @localOnly.
  ///
  /// In es, this message translates to:
  /// **'Todo lo que añadas se guarda solo en este teléfono.'**
  String get localOnly;

  /// No description provided for @addPrompt.
  ///
  /// In es, this message translates to:
  /// **'Añadir consigna'**
  String get addPrompt;

  /// No description provided for @ownCategories.
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍAS PROPIAS'**
  String get ownCategories;

  /// No description provided for @ownPromptCount.
  ///
  /// In es, this message translates to:
  /// **'{count} consignas propias'**
  String ownPromptCount(int count);

  /// No description provided for @noOwnCategories.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has creado ninguna.'**
  String get noOwnCategories;

  /// No description provided for @ownPrompts.
  ///
  /// In es, this message translates to:
  /// **'CONSIGNAS AÑADIDAS'**
  String get ownPrompts;

  /// No description provided for @noOwnPrompts.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has añadido ninguna.'**
  String get noOwnPrompts;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar categoría?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán la categoría «{category}» y todas sus consignas.'**
  String deleteCategoryMessage(String category);

  /// No description provided for @deletePromptTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar consigna?'**
  String get deletePromptTitle;

  /// No description provided for @deletePromptMessage.
  ///
  /// In es, this message translates to:
  /// **'La consigna «{prompt}» dejará de aparecer en el juego.'**
  String deletePromptMessage(String prompt);

  /// No description provided for @categoryDeleted.
  ///
  /// In es, this message translates to:
  /// **'Categoría eliminada'**
  String get categoryDeleted;

  /// No description provided for @promptDeleted.
  ///
  /// In es, this message translates to:
  /// **'Consigna eliminada'**
  String get promptDeleted;

  /// No description provided for @lastPromptDeleted.
  ///
  /// In es, this message translates to:
  /// **'Se eliminó también la categoría porque no tenía más consignas'**
  String get lastPromptDeleted;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @lightMode.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get lightMode;

  /// No description provided for @darkDefault.
  ///
  /// In es, this message translates to:
  /// **'El modo oscuro seguirá siendo el predeterminado'**
  String get darkDefault;

  /// No description provided for @categoriesAndPrompts.
  ///
  /// In es, this message translates to:
  /// **'Categorías y consignas'**
  String get categoriesAndPrompts;

  /// No description provided for @addLocalContent.
  ///
  /// In es, this message translates to:
  /// **'Añade contenido propio guardado en este teléfono'**
  String get addLocalContent;

  /// No description provided for @bombSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido de la bomba'**
  String get bombSound;

  /// No description provided for @soundEnabled.
  ///
  /// In es, this message translates to:
  /// **'Tic-tac continuo y explosión activados'**
  String get soundEnabled;

  /// No description provided for @soundDisabled.
  ///
  /// In es, this message translates to:
  /// **'Tic-tac y explosión desactivados'**
  String get soundDisabled;

  /// No description provided for @vibration.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get vibration;

  /// No description provided for @vibrationEnabled.
  ///
  /// In es, this message translates to:
  /// **'Impacto háptico al explotar'**
  String get vibrationEnabled;

  /// No description provided for @vibrationDisabled.
  ///
  /// In es, this message translates to:
  /// **'La bomba no vibrará al explotar'**
  String get vibrationDisabled;

  /// No description provided for @rateApp.
  ///
  /// In es, this message translates to:
  /// **'Valorar la aplicación'**
  String get rateApp;

  /// No description provided for @rateAppDescription.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu opinión en Google Play'**
  String get rateAppDescription;

  /// No description provided for @ratePromptTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Te está gustando La Bomba?'**
  String get ratePromptTitle;

  /// No description provided for @ratePromptMessage.
  ///
  /// In es, this message translates to:
  /// **'Tu valoración nos ayuda a mejorar el juego y llegar a más jugadores.'**
  String get ratePromptMessage;

  /// No description provided for @rateNow.
  ///
  /// In es, this message translates to:
  /// **'Valorar ahora'**
  String get rateNow;

  /// No description provided for @later.
  ///
  /// In es, this message translates to:
  /// **'Más adelante'**
  String get later;

  /// No description provided for @moreGames.
  ///
  /// In es, this message translates to:
  /// **'MÁS JUEGOS'**
  String get moreGames;

  /// No description provided for @playTruthOrDare.
  ///
  /// In es, this message translates to:
  /// **'Jugar a Verdad o Reto'**
  String get playTruthOrDare;

  /// No description provided for @playImpostor.
  ///
  /// In es, this message translates to:
  /// **'Jugar a Impostor'**
  String get playImpostor;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In es, this message translates to:
  /// **'Idioma de los textos de la aplicación'**
  String get languageDescription;

  /// No description provided for @languageAutomatic.
  ///
  /// In es, this message translates to:
  /// **'Automático (dispositivo)'**
  String get languageAutomatic;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// No description provided for @gameReminders.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios para jugar'**
  String get gameReminders;

  /// No description provided for @remindersEnabled.
  ///
  /// In es, this message translates to:
  /// **'Jueves, viernes y sábado a las 21:10'**
  String get remindersEnabled;

  /// No description provided for @remindersDisabled.
  ///
  /// In es, this message translates to:
  /// **'No recibirás recordatorios para jugar'**
  String get remindersDisabled;

  /// No description provided for @privacyOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones de privacidad'**
  String get privacyOptions;

  /// No description provided for @privacyOptionsDescription.
  ///
  /// In es, this message translates to:
  /// **'Gestiona el consentimiento y la personalización de anuncios'**
  String get privacyOptionsDescription;

  /// No description provided for @lightFuseRandom.
  ///
  /// In es, this message translates to:
  /// **'Encender mecha (Al azar)'**
  String get lightFuseRandom;

  /// No description provided for @orChooseCategory.
  ///
  /// In es, this message translates to:
  /// **'O elige categoría'**
  String get orChooseCategory;

  /// No description provided for @createMine.
  ///
  /// In es, this message translates to:
  /// **'Crear mía'**
  String get createMine;

  /// No description provided for @tapAndPlay.
  ///
  /// In es, this message translates to:
  /// **'Tocar y jugar'**
  String get tapAndPlay;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get filterAll;

  /// No description provided for @filterFavorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritas'**
  String get filterFavorites;

  /// No description provided for @filterMine.
  ///
  /// In es, this message translates to:
  /// **'Mías'**
  String get filterMine;

  /// No description provided for @noFavoritesYet.
  ///
  /// In es, this message translates to:
  /// **'Toca la estrella en cualquier categoría para tenerla aquí arriba.'**
  String get noFavoritesYet;

  /// No description provided for @rewards.
  ///
  /// In es, this message translates to:
  /// **'Recompensas'**
  String get rewards;

  /// No description provided for @sparksTooltip.
  ///
  /// In es, this message translates to:
  /// **'Chispas y recompensas'**
  String get sparksTooltip;

  /// No description provided for @earnSparksTitle.
  ///
  /// In es, this message translates to:
  /// **'Gana +50 Chispas gratis'**
  String get earnSparksTitle;

  /// No description provided for @earnSparksSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mira un anuncio corto para desbloquear packs y aspectos sin pagar.'**
  String get earnSparksSubtitle;

  /// No description provided for @watchAdEarn.
  ///
  /// In es, this message translates to:
  /// **'Ver anuncio (+50 ⚡)'**
  String get watchAdEarn;

  /// No description provided for @specialPacks.
  ///
  /// In es, this message translates to:
  /// **'PACKS ESPECIALES'**
  String get specialPacks;

  /// No description provided for @bombSkins.
  ///
  /// In es, this message translates to:
  /// **'ASPECTOS DE LA BOMBA'**
  String get bombSkins;

  /// No description provided for @unlockWithAd24h.
  ///
  /// In es, this message translates to:
  /// **'1 anuncio (24h)'**
  String get unlockWithAd24h;

  /// No description provided for @unlockWithSparks.
  ///
  /// In es, this message translates to:
  /// **'{cost} ⚡'**
  String unlockWithSparks(int cost);

  /// No description provided for @active24h.
  ///
  /// In es, this message translates to:
  /// **'Activo 24h'**
  String get active24h;

  /// No description provided for @unlocked.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueado'**
  String get unlocked;

  /// No description provided for @equipped.
  ///
  /// In es, this message translates to:
  /// **'Equipada'**
  String get equipped;

  /// No description provided for @equip.
  ///
  /// In es, this message translates to:
  /// **'Equipar'**
  String get equip;

  /// No description provided for @freeLabel.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get freeLabel;

  /// No description provided for @adNotReady.
  ///
  /// In es, this message translates to:
  /// **'No hay anuncio disponible ahora mismo. Inténtalo en unos segundos.'**
  String get adNotReady;

  /// No description provided for @rewardEarnedSparks.
  ///
  /// In es, this message translates to:
  /// **'¡+{amount} ⚡ Chispas añadidas!'**
  String rewardEarnedSparks(int amount);

  /// No description provided for @packUnlocked24h.
  ///
  /// In es, this message translates to:
  /// **'Pack «{pack}» desbloqueado durante 24h'**
  String packUnlocked24h(String pack);

  /// No description provided for @packUnlockedForever.
  ///
  /// In es, this message translates to:
  /// **'Pack «{pack}» desbloqueado para siempre'**
  String packUnlockedForever(String pack);

  /// No description provided for @skinUnlocked.
  ///
  /// In es, this message translates to:
  /// **'Aspecto «{skin}» desbloqueado y equipado'**
  String skinUnlocked(String skin);

  /// No description provided for @notEnoughSparks.
  ///
  /// In es, this message translates to:
  /// **'Te faltan Chispas ⚡. Mira un anuncio arriba para conseguir más.'**
  String get notEnoughSparks;

  /// No description provided for @swapsLeft.
  ///
  /// In es, this message translates to:
  /// **'Cambiar consigna ({count})'**
  String swapsLeft(int count);

  /// No description provided for @watchAdMoreSwaps.
  ///
  /// In es, this message translates to:
  /// **'Ver anuncio (+3 cambios)'**
  String get watchAdMoreSwaps;

  /// No description provided for @swapsRecharged.
  ///
  /// In es, this message translates to:
  /// **'+3 cambios de consigna desbloqueados'**
  String get swapsRecharged;

  /// No description provided for @loserDareTitle.
  ///
  /// In es, this message translates to:
  /// **'RETO DEL PERDEDOR'**
  String get loserDareTitle;

  /// No description provided for @anotherDare.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get anotherDare;

  /// No description provided for @roundSparksBonus.
  ///
  /// In es, this message translates to:
  /// **'+10 ⚡ por completar la ronda'**
  String get roundSparksBonus;

  /// No description provided for @watchAdBonusSparks.
  ///
  /// In es, this message translates to:
  /// **'Ver anuncio y ganar +30 ⚡'**
  String get watchAdBonusSparks;

  /// No description provided for @loserDareSetting.
  ///
  /// In es, this message translates to:
  /// **'Reto del perdedor'**
  String get loserDareSetting;

  /// No description provided for @loserDareEnabled.
  ///
  /// In es, this message translates to:
  /// **'Muestra un mini-reto opcional al explotar'**
  String get loserDareEnabled;

  /// No description provided for @loserDareDisabled.
  ///
  /// In es, this message translates to:
  /// **'Sin retos al final de la ronda'**
  String get loserDareDisabled;

  /// No description provided for @dynamicTension.
  ///
  /// In es, this message translates to:
  /// **'Tensión dinámica'**
  String get dynamicTension;

  /// No description provided for @dynamicTensionEnabled.
  ///
  /// In es, this message translates to:
  /// **'El tic-tac se acelera en el tramo final'**
  String get dynamicTensionEnabled;

  /// No description provided for @dynamicTensionDisabled.
  ///
  /// In es, this message translates to:
  /// **'Ritmo de tic-tac constante'**
  String get dynamicTensionDisabled;

  /// No description provided for @sectionGameAudio.
  ///
  /// In es, this message translates to:
  /// **'JUEGO Y AUDIO'**
  String get sectionGameAudio;

  /// No description provided for @sectionAppearance.
  ///
  /// In es, this message translates to:
  /// **'APARIENCIA E IDIOMA'**
  String get sectionAppearance;

  /// No description provided for @sectionContent.
  ///
  /// In es, this message translates to:
  /// **'CONTENIDO Y PRIVACIDAD'**
  String get sectionContent;

  /// No description provided for @skinClassic.
  ///
  /// In es, this message translates to:
  /// **'Clásica'**
  String get skinClassic;

  /// No description provided for @skinNeon.
  ///
  /// In es, this message translates to:
  /// **'Neón'**
  String get skinNeon;

  /// No description provided for @skinDynamite.
  ///
  /// In es, this message translates to:
  /// **'Dinamita'**
  String get skinDynamite;

  /// No description provided for @skinGold.
  ///
  /// In es, this message translates to:
  /// **'Dorada'**
  String get skinGold;

  /// No description provided for @packPromptCount.
  ///
  /// In es, this message translates to:
  /// **'{count} consignas exclusivas'**
  String packPromptCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
