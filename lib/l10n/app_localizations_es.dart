// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'La Bomba';

  @override
  String get howToPlay => 'CÓMO SE JUEGA';

  @override
  String get tutorialTitle => 'Que la bomba os\npille preparados.';

  @override
  String get phoneCenterTitle => 'Móvil en el centro';

  @override
  String get phoneCenterText =>
      'Dejadlo donde todos puedan verlo y escucharlo.';

  @override
  String get chooseActivateTitle => 'Elegid y activad una categoría';

  @override
  String get chooseActivateText =>
      'Nombrad respuestas válidas hasta que la bomba explote.';

  @override
  String get whoStartsTitle => 'Quién empieza';

  @override
  String get whoStartsText =>
      'La primera ronda empieza el dueño del móvil. Después, empieza quien perdió la ronda anterior.';

  @override
  String get tutorialDone => 'Entendido, vamos a jugar';

  @override
  String get settingsTooltip => 'Configuración';

  @override
  String get darkModeTooltip => 'Modo oscuro';

  @override
  String get lightModeTooltip => 'Modo claro';

  @override
  String get homeTitle => 'Nombra cosas.\nQue no te pille.';

  @override
  String get homeDescription =>
      'Elegid una categoría y decid respuestas sin repetir hasta que la bomba explote.';

  @override
  String get chooseCategory => 'Elegir categoría';

  @override
  String get homeFooter => 'SIN NOMBRES · SIN JUGADORES · SIN TURNOS';

  @override
  String get chooseCategoryTitle => 'Elige una categoría';

  @override
  String get everyonePlays => 'Todo el grupo juega a la vez.';

  @override
  String get chosenCategory => 'CATEGORÍA ELEGIDA';

  @override
  String get quick => 'Rápida';

  @override
  String get normal => 'Normal';

  @override
  String get long => 'Larga';

  @override
  String explosionRange(int min, int max) {
    return 'La explosión ocurrirá entre $min y $max segundos.';
  }

  @override
  String get lightFuse => 'Encender la mecha';

  @override
  String get cancelCountdown => 'Cancelar cuenta atrás';

  @override
  String get previousLoserStarts => 'EMPIEZA QUIEN PERDIÓ\nLA RONDA ANTERIOR';

  @override
  String get chooseWhoStarts => 'ELEGID QUIÉN EMPIEZA';

  @override
  String get bombStartsAtZero => 'La bomba se encenderá al llegar a cero';

  @override
  String get paused => 'EN PAUSA';

  @override
  String get tickTock => 'TIC · TAC · TIC · TAC';

  @override
  String get changePrompt => 'Cambiar consigna';

  @override
  String get tapToContinue => 'Pulsa ▶ para continuar';

  @override
  String get keepAnswering => 'Seguid respondiendo hasta que explote';

  @override
  String get boom => '¡BOOM!';

  @override
  String get lostRound => 'Has perdido esta ronda';

  @override
  String anotherFrom(String category) {
    return 'Otra de $category';
  }

  @override
  String get changeCategory => 'Cambiar categoría';

  @override
  String get newPrompt => 'Nueva consigna';

  @override
  String get category => 'Categoría';

  @override
  String get prompt => 'Consigna';

  @override
  String get promptHint => 'Ej. Cosas que llevarías a Marte';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get createCategory => 'Crear categoría';

  @override
  String get name => 'Nombre';

  @override
  String get icon => 'Icono';

  @override
  String get emojiHelp => 'Puedes pegar cualquier emoji';

  @override
  String get firstPrompt => 'Primera consigna';

  @override
  String get create => 'Crear';

  @override
  String get promptAdded => 'Consigna añadida';

  @override
  String get newPromptRequired => 'Escribe una consigna nueva';

  @override
  String get categoryCreated => 'Categoría creada';

  @override
  String get categoryReview => 'Revisa el nombre y la consigna';

  @override
  String get yourContent => 'Tu contenido';

  @override
  String get customizeGame => 'Personaliza el juego';

  @override
  String get localOnly => 'Todo lo que añadas se guarda solo en este teléfono.';

  @override
  String get addPrompt => 'Añadir consigna';

  @override
  String get ownCategories => 'CATEGORÍAS PROPIAS';

  @override
  String ownPromptCount(int count) {
    return '$count consignas propias';
  }

  @override
  String get noOwnCategories => 'Todavía no has creado ninguna.';

  @override
  String get ownPrompts => 'CONSIGNAS AÑADIDAS';

  @override
  String get noOwnPrompts => 'Todavía no has añadido ninguna.';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteCategoryTitle => '¿Eliminar categoría?';

  @override
  String deleteCategoryMessage(String category) {
    return 'Se eliminarán la categoría «$category» y todas sus consignas.';
  }

  @override
  String get deletePromptTitle => '¿Eliminar consigna?';

  @override
  String deletePromptMessage(String prompt) {
    return 'La consigna «$prompt» dejará de aparecer en el juego.';
  }

  @override
  String get categoryDeleted => 'Categoría eliminada';

  @override
  String get promptDeleted => 'Consigna eliminada';

  @override
  String get lastPromptDeleted =>
      'Se eliminó también la categoría porque no tenía más consignas';

  @override
  String get settings => 'Configuración';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get darkDefault => 'El modo oscuro seguirá siendo el predeterminado';

  @override
  String get categoriesAndPrompts => 'Categorías y consignas';

  @override
  String get addLocalContent =>
      'Añade contenido propio guardado en este teléfono';

  @override
  String get bombSound => 'Sonido de la bomba';

  @override
  String get soundEnabled => 'Tic-tac continuo y explosión activados';

  @override
  String get soundDisabled => 'Tic-tac y explosión desactivados';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrationEnabled => 'Impacto háptico al explotar';

  @override
  String get vibrationDisabled => 'La bomba no vibrará al explotar';

  @override
  String get rateApp => 'Valorar la aplicación';

  @override
  String get rateAppDescription => 'Comparte tu opinión en Google Play';

  @override
  String get ratePromptTitle => '¿Te está gustando La Bomba?';

  @override
  String get ratePromptMessage =>
      'Tu valoración nos ayuda a mejorar el juego y llegar a más jugadores.';

  @override
  String get rateNow => 'Valorar ahora';

  @override
  String get later => 'Más adelante';

  @override
  String get moreGames => 'MÁS JUEGOS';

  @override
  String get playTruthOrDare => 'Jugar a Verdad o Reto';

  @override
  String get playImpostor => 'Jugar a Impostor';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Idioma de los textos de la aplicación';

  @override
  String get languageAutomatic => 'Automático (dispositivo)';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get gameReminders => 'Recordatorios para jugar';

  @override
  String get remindersEnabled => 'Jueves, viernes y sábado a las 21:10';

  @override
  String get remindersDisabled => 'No recibirás recordatorios para jugar';

  @override
  String get privacyOptions => 'Opciones de privacidad';

  @override
  String get privacyOptionsDescription =>
      'Gestiona el consentimiento y la personalización de anuncios';

  @override
  String get lightFuseRandom => 'Encender mecha (Al azar)';

  @override
  String get orChooseCategory => 'O elige categoría';

  @override
  String get createMine => 'Crear mía';

  @override
  String get tapAndPlay => 'Tocar y jugar';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterFavorites => 'Favoritas';

  @override
  String get filterMine => 'Mías';

  @override
  String get noFavoritesYet =>
      'Toca la estrella en cualquier categoría para tenerla aquí arriba.';

  @override
  String get rewards => 'Recompensas';

  @override
  String get sparksTooltip => 'Chispas y recompensas';

  @override
  String get earnSparksTitle => 'Gana +50 Chispas gratis';

  @override
  String get earnSparksSubtitle =>
      'Mira un anuncio corto para desbloquear packs y aspectos sin pagar.';

  @override
  String get watchAdEarn => 'Ver anuncio (+50 ⚡)';

  @override
  String get specialPacks => 'PACKS ESPECIALES';

  @override
  String get bombSkins => 'ASPECTOS DE LA BOMBA';

  @override
  String get unlockWithAd24h => '1 anuncio (24h)';

  @override
  String unlockWithSparks(int cost) {
    return '$cost ⚡';
  }

  @override
  String get active24h => 'Activo 24h';

  @override
  String get unlocked => 'Desbloqueado';

  @override
  String get equipped => 'Equipada';

  @override
  String get equip => 'Equipar';

  @override
  String get freeLabel => 'Gratis';

  @override
  String get adNotReady =>
      'No hay anuncio disponible ahora mismo. Inténtalo en unos segundos.';

  @override
  String rewardEarnedSparks(int amount) {
    return '¡+$amount ⚡ Chispas añadidas!';
  }

  @override
  String packUnlocked24h(String pack) {
    return 'Pack «$pack» desbloqueado durante 24h';
  }

  @override
  String packUnlockedForever(String pack) {
    return 'Pack «$pack» desbloqueado para siempre';
  }

  @override
  String skinUnlocked(String skin) {
    return 'Aspecto «$skin» desbloqueado y equipado';
  }

  @override
  String get notEnoughSparks =>
      'Te faltan Chispas ⚡. Mira un anuncio arriba para conseguir más.';

  @override
  String swapsLeft(int count) {
    return 'Cambiar consigna ($count)';
  }

  @override
  String get watchAdMoreSwaps => 'Ver anuncio (+3 cambios)';

  @override
  String get swapsRecharged => '+3 cambios de consigna desbloqueados';

  @override
  String get loserDareTitle => 'RETO DEL PERDEDOR';

  @override
  String get anotherDare => 'Otro';

  @override
  String get roundSparksBonus => '+10 ⚡ por completar la ronda';

  @override
  String get watchAdBonusSparks => 'Ver anuncio y ganar +30 ⚡';

  @override
  String get loserDareSetting => 'Reto del perdedor';

  @override
  String get loserDareEnabled => 'Muestra un mini-reto opcional al explotar';

  @override
  String get loserDareDisabled => 'Sin retos al final de la ronda';

  @override
  String get dynamicTension => 'Tensión dinámica';

  @override
  String get dynamicTensionEnabled => 'El tic-tac se acelera en el tramo final';

  @override
  String get dynamicTensionDisabled => 'Ritmo de tic-tac constante';

  @override
  String get sectionGameAudio => 'JUEGO Y AUDIO';

  @override
  String get sectionAppearance => 'APARIENCIA E IDIOMA';

  @override
  String get sectionContent => 'CONTENIDO Y PRIVACIDAD';

  @override
  String get skinClassic => 'Clásica';

  @override
  String get skinNeon => 'Neón';

  @override
  String get skinDynamite => 'Dinamita';

  @override
  String get skinGold => 'Dorada';

  @override
  String packPromptCount(int count) {
    return '$count consignas exclusivas';
  }
}
