// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Lunanul';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get cardOfTheDay => 'Carta del Día';

  @override
  String get tapToReveal => 'Toca la carta para revelar tu guía diaria';

  @override
  String get recentReadings => 'Lecturas Recientes';

  @override
  String get dailyReflection => 'Reflexión Diaria';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get welcomeMessage =>
      'Bienvenido a tu santuario personal de reflexión e introspección.';

  @override
  String get noReadingsYet => 'Aún no hay lecturas';

  @override
  String get startReading => 'Comenzar Lectura';

  @override
  String get newCard => 'Nueva Carta';

  @override
  String get journal => 'Diario';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get reflect => 'Reflexionar';

  @override
  String get newPrompt => 'Nueva pregunta';

  @override
  String get drawingCard => 'Sacando tu carta...';

  @override
  String get loadingReadings => 'Cargando lecturas...';

  @override
  String get unableToLoadCard => 'No se pudo cargar tu carta';

  @override
  String get unableToLoadReadings => 'No se pudieron cargar las lecturas';

  @override
  String get pleaseRetry => 'Por favor inténtalo de nuevo';

  @override
  String get retry => 'Reintentar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get startJourney => 'Comienza tu viaje con una nueva lectura';

  @override
  String get fullHistoryComingSoon => '¡El historial completo llegará pronto!';

  @override
  String get journalPageComingSoon => '¡La página del diario llegará pronto!';

  @override
  String get navigateToReadingsPage => 'Navegar a la página de lecturas';

  @override
  String get manualInterpretations => 'Interpretaciones Manuales';

  @override
  String get inputPhysicalDeck =>
      'Ingresa las cartas de tu baraja física para obtener perspectivas mejoradas con IA';

  @override
  String get selectReadingContext => 'Selecciona el contexto de lectura';

  @override
  String get searchCardsHint => 'Buscar cartas por nombre o palabras clave...';

  @override
  String get noCardsFound => 'No se encontraron cartas';

  @override
  String get tryAdjustingSearch => 'Intenta ajustar tu búsqueda o filtro';

  @override
  String get selectCard => 'Seleccionar una Carta';

  @override
  String get selectCardOrientation => 'Seleccionar Orientación de la Carta';

  @override
  String get chooseCardPosition =>
      'Elige cómo apareció esta carta en tu lectura:';

  @override
  String get upright => 'Derecha';

  @override
  String get reversed => 'Invertidas';

  @override
  String get allCards => 'Todas';

  @override
  String get chooseAreaOfLife =>
      'Elige el área de la vida que quieres explorar';

  @override
  String get addYourCards => 'Añade tus cartas';

  @override
  String get selectCardsFromDeck =>
      'Selecciona las cartas que sacaste de tu baraja física';

  @override
  String get pleaseSelectContext =>
      'Por favor selecciona un contexto de lectura primero';

  @override
  String get addCardFromDeck => 'Añadir Carta de la Baraja';

  @override
  String get clearAll => 'Limpiar Todo';

  @override
  String get saveReading => 'Guardar Lectura';

  @override
  String get saveInterpretation => 'Guardar interpretación';

  @override
  String get startOver => 'Empezar de nuevo';

  @override
  String get selectedCards => 'Cartas Seleccionadas';

  @override
  String get noCardsSelected => 'No hay cartas seleccionadas';

  @override
  String get editPositionName => 'Editar Nombre de Posición';

  @override
  String get positionName => 'Nombre de Posición';

  @override
  String get positionNameHint => 'ej., Pasado, Presente, Futuro';

  @override
  String get cardConnections => 'Conexiones de Cartas';

  @override
  String get recentManualInterpretations =>
      'Interpretaciones Manuales Recientes';

  @override
  String get noManualInterpretations => 'Aún no hay interpretaciones manuales';

  @override
  String get addCardsToGetStarted =>
      'Añade cartas de tu baraja física para comenzar';

  @override
  String get interpretationDetailsComingSoon =>
      'Los detalles de interpretación llegarán pronto';

  @override
  String get failedToLoadInterpretations => 'Error al cargar interpretaciones';

  @override
  String get saveInterpretationDialog => 'Guardar Interpretación';

  @override
  String get saveInterpretationQuestion =>
      '¿Guardar esta interpretación manual en tu diario?';

  @override
  String get personalNotes => 'Notas personales (opcional)';

  @override
  String get addThoughts => 'Añade tus pensamientos sobre esta lectura...';

  @override
  String get interpretationSaved => 'Interpretación guardada en el diario';

  @override
  String get failedToSave => 'Error al guardar';

  @override
  String get navigationHome => 'Inicio';

  @override
  String get navigationReadings => 'Lecturas';

  @override
  String get navigationManual => 'Manual';

  @override
  String get navigationYourself => 'Tú Mismo';

  @override
  String get navigationFriends => 'Amigos';

  @override
  String get readingDetails => 'Detalles de la Lectura';

  @override
  String get yourReflection => 'Tu Reflexión';

  @override
  String get readingStatistics => 'Estadísticas de Lectura';

  @override
  String get majorArcana => 'Arcanos Mayores';

  @override
  String get suits => 'Palos';

  @override
  String get share => 'Compartir';

  @override
  String get delete => 'Eliminar';

  @override
  String get imageUnavailable => 'Imagen no disponible';

  @override
  String get removeFriend => 'Eliminar Amigo';

  @override
  String removeFriendConfirm(String friendName) {
    return '¿Estás seguro de que quieres eliminar a $friendName de tus amigos?';
  }

  @override
  String get remove => 'Eliminar';

  @override
  String get activeNow => 'Activo ahora';

  @override
  String activeMinutesAgo(int minutes) {
    return 'Activo hace ${minutes}m';
  }

  @override
  String activeHoursAgo(int hours) {
    return 'Activo hace ${hours}h';
  }

  @override
  String get activeYesterday => 'Activo ayer';

  @override
  String activeDaysAgo(int days) {
    return 'Activo hace $days días';
  }

  @override
  String get today => 'hoy';

  @override
  String get yesterday => 'ayer';

  @override
  String daysAgo(int days) {
    return 'hace $days días';
  }

  @override
  String get startConversation => 'Iniciar la conversación';

  @override
  String get shareThoughts =>
      'Comparte tus pensamientos sobre esta lectura con tu amigo';

  @override
  String get spreadPast => 'Pasado';

  @override
  String get spreadPresent => 'Presente';

  @override
  String get spreadFuture => 'Futuro';

  @override
  String get spreadYou => 'Tú';

  @override
  String get spreadThem => 'Ellos';

  @override
  String get spreadConnection => 'Conexión';

  @override
  String get spreadCurrentSituation => 'Situación Actual';

  @override
  String get spreadStrengths => 'Fortalezas';

  @override
  String get spreadChallenges => 'Desafíos';

  @override
  String get topicSelf => 'Yo';

  @override
  String get topicLove => 'Amor';

  @override
  String get topicWork => 'Trabajo';

  @override
  String get topicSocial => 'Social';

  @override
  String get topicSelfDescription =>
      'Crecimiento personal y autodescubrimiento';

  @override
  String get topicLoveDescription => 'Relaciones y conexiones emocionales';

  @override
  String get topicWorkDescription => 'Carrera y vida profesional';

  @override
  String get topicSocialDescription => 'Comunidad e interacciones sociales';

  @override
  String get readingJournal => 'Diario de Lecturas';

  @override
  String get searchReadings => 'Buscar lecturas...';

  @override
  String get all => 'Todas';

  @override
  String get noReadingsFound => 'No se encontraron lecturas';

  @override
  String get tryAdjustingFilters => 'Intenta ajustar tu búsqueda o filtros';

  @override
  String get noJournalEntries => 'Aún no hay entradas en el diario';

  @override
  String get saveReadingsToStart =>
      'Guarda lecturas para comenzar a construir tu diario';

  @override
  String get createReading => 'Crear Lectura';

  @override
  String get unableToLoadJournal => 'No se pudo cargar el diario';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get deleteReading => 'Eliminar Lectura';

  @override
  String deleteReadingConfirm(String title) {
    return '¿Estás seguro de que quieres eliminar \"$title\"? Esta acción no se puede deshacer.';
  }

  @override
  String get readingDeletedSuccess => 'Lectura eliminada exitosamente';

  @override
  String get failedToDeleteReading => 'Error al eliminar la lectura';

  @override
  String get friends => 'Amigos';

  @override
  String get addFriend => 'Añadir Amigo';

  @override
  String get shareYourJourney => 'Comparte tu viaje';

  @override
  String get connectWithFriends =>
      'Conecta con amigos de confianza y comparte lecturas significativas';

  @override
  String get yourFriends => 'Tus Amigos';

  @override
  String get noFriendsYet => 'Aún no tienes amigos';

  @override
  String get addFriendsToShare =>
      'Añade amigos para compartir tu viaje del tarot de forma privada';

  @override
  String get addYourFirstFriend => 'Añadir Tu Primer Amigo';

  @override
  String get errorLoadingFriends => 'Error al cargar amigos';

  @override
  String get sharedReadings => 'Lecturas Compartidas';

  @override
  String get noSharedReadings => 'No hay lecturas compartidas';

  @override
  String get shareReadingsFromJournal =>
      'Comparte lecturas de tu diario para iniciar conversaciones';

  @override
  String get errorLoadingSharedReadings =>
      'Error al cargar lecturas compartidas';

  @override
  String get errorLoadingUserData => 'Error al cargar datos del usuario';

  @override
  String get privacySafety => 'Privacidad y Seguridad';

  @override
  String get privacyInfo =>
      '• Los amigos solo se pueden añadir a través de códigos de invitación privados\n• Tú controlas qué lecturas compartir\n• Todas las conversaciones son privadas entre tú y tu amigo\n• Puedes eliminar amigos en cualquier momento';

  @override
  String get chooseHowToConnect => 'Elige cómo conectar con tu amigo:';

  @override
  String get shareInvitationCode => 'Compartir Código de Invitación';

  @override
  String get enterFriendsCode => 'Ingresar Código del Amigo';

  @override
  String get yourInvitationCode => 'Tu Código de Invitación';

  @override
  String get shareThisCode => 'Comparte este código con tu amigo:';

  @override
  String get copyCode => 'Copiar Código';

  @override
  String get codeCopiedToClipboard => 'Código copiado al portapapeles';

  @override
  String errorGeneratingCode(String error) {
    return 'Error al generar código: $error';
  }

  @override
  String get done => 'Listo';

  @override
  String get codeUniqueToYou =>
      'Este código es único para ti y se puede usar múltiples veces';

  @override
  String get enterFriendsCodeDialog => 'Ingresar Código del Amigo';

  @override
  String get enterInvitationCode =>
      'Ingresa el código de invitación que tu amigo compartió:';

  @override
  String get invitationCode => 'Código de Invitación';

  @override
  String get invitationCodeHint => 'LUNA-1234-ABC567';

  @override
  String get sendRequest => 'Enviar Solicitud';

  @override
  String get pleaseEnterCode => 'Por favor ingresa un código de invitación';

  @override
  String get sendingFriendRequest => 'Enviando solicitud de amistad...';

  @override
  String get friendRequestSentSuccess =>
      '¡Solicitud de amistad enviada exitosamente!';

  @override
  String failedToSendFriendRequest(String error) {
    return 'Error al enviar solicitud de amistad: $error';
  }

  @override
  String friendRemovedSuccess(String name) {
    return '$name eliminado de amigos';
  }

  @override
  String failedToRemoveFriend(String error) {
    return 'Error al eliminar amigo: $error';
  }

  @override
  String get readings => 'Lecturas';

  @override
  String get chooseTopicForReading => 'Elige un tema para tu lectura';

  @override
  String get aiPoweredInsights =>
      'Deja que las cartas te guíen con perspectivas potenciadas por IA';

  @override
  String get recentSavedReadings => 'Lecturas Guardadas Recientes';

  @override
  String get navigateToYourselfPage =>
      'Navega a la página Tú Mismo para ver todas las lecturas';

  @override
  String get noSavedReadingsYet => 'Aún no hay lecturas guardadas';

  @override
  String get completeReadingToSee =>
      'Completa una lectura arriba y guárdala para verla aquí';

  @override
  String get saveReadingDialog => 'Guardar Lectura';

  @override
  String get addThoughtsOptional =>
      'Añade tus pensamientos sobre esta lectura (opcional)...';

  @override
  String get saving => 'Guardando...';

  @override
  String get readingSavedToJournal => 'Lectura guardada en tu diario';

  @override
  String get failedToSaveReading => 'Error al guardar la lectura';

  @override
  String get saved => 'Guardada';

  @override
  String get alreadySaved => 'Ya guardada';

  @override
  String get readingSaved => 'Lectura guardada';

  @override
  String get shareReading => 'Compartir Lectura';

  @override
  String cardsSpread(int count, String spread) {
    return '$count cartas • $spread';
  }

  @override
  String get chooseFriendToShare => 'Elige un amigo para compartir:';

  @override
  String get noFriendsToShareWith => 'No hay amigos para compartir';

  @override
  String get addFriendsToStartSharing =>
      'Añade amigos para comenzar a compartir lecturas';

  @override
  String get sharingReading => 'Compartiendo lectura...';

  @override
  String readingSharedWith(String name) {
    return 'Lectura compartida con $name';
  }

  @override
  String failedToShareReading(String error) {
    return 'Error al compartir lectura: $error';
  }

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get languageSelection => 'Selección de Idioma';

  @override
  String get chooseLanguage => 'Elige tu idioma preferido';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String currentLanguage(String language) {
    return 'Idioma actual: $language';
  }

  @override
  String languageChanged(String language) {
    return 'Idioma cambiado a $language';
  }

  @override
  String get yourTarotJourney => 'Tu viaje del tarot';

  @override
  String get reflectOnReadings =>
      'Reflexiona sobre tus lecturas y explora las cartas';

  @override
  String get yourJourney => 'Tu Viaje';

  @override
  String get totalReadings => 'Lecturas Totales';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get favoriteTopic => 'Tema Favorito';

  @override
  String get none => 'Ninguno';

  @override
  String get readingJournalDescription =>
      'Ve y reflexiona sobre tus lecturas guardadas';

  @override
  String get cardEncyclopedia => 'Enciclopedia de Cartas';

  @override
  String get cardEncyclopediaDescription =>
      'Aprende sobre las 78 cartas del tarot';

  @override
  String get readingPatterns => 'Patrones de Lectura';

  @override
  String get readingPatternsDescription =>
      'Descubre temas y cartas recurrentes';

  @override
  String get settingsDescription =>
      'Preferencias de idioma y configuración de la app';

  @override
  String get recentJournalEntries => 'Entradas Recientes del Diario';

  @override
  String get noJournalEntriesYet => 'Aún no hay entradas en el diario';

  @override
  String get saveReadingsToBuildJournal =>
      'Guarda lecturas para comenzar a construir tu diario';

  @override
  String cardsCount(int count) {
    return '$count cartas';
  }

  @override
  String get unableToLoadStats => 'No se pudieron cargar las estadísticas';

  @override
  String get unableToLoadJournalEntries =>
      'No se pudieron cargar las entradas del diario';

  @override
  String get chooseYourSpread => 'Elige tu Tirada';

  @override
  String get selectSpreadType =>
      'Selecciona el tipo de lectura que resuene con tu pregunta';

  @override
  String get selectASpread => 'Selecciona una Tirada';

  @override
  String startSpreadReading(String spreadName) {
    return 'Comenzar Lectura de $spreadName';
  }

  @override
  String get shufflingCards => 'Barajando las cartas...';

  @override
  String get universePreparingReading =>
      'El universo está preparando tu lectura';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get unableToCreateReading =>
      'No se pudo crear tu lectura. Por favor inténtalo de nuevo.';

  @override
  String get goBack => 'Volver';

  @override
  String get cardsBeingDealt => 'Las cartas se están repartiendo...';

  @override
  String get watchCardsPlaced =>
      'Observa cómo tus cartas se colocan en sus posiciones';

  @override
  String get tapToRevealCards => 'Toca para revelar tus cartas';

  @override
  String get touchCardWhenReady =>
      'Toca cada carta cuando estés listo para ver su mensaje';

  @override
  String get yourReading => 'Tu Lectura';

  @override
  String get saveToJournal => 'Guardar en Diario';

  @override
  String get newReading => 'Nueva Lectura';

  @override
  String get guideSageName => 'Zian';

  @override
  String get guideSageTitle => 'El Místico Sabio';

  @override
  String get guideSageDescription =>
      'Un guía profundo que habla en verdades cósmicas y sabiduría universal, ayudándote a entender los patrones espirituales más profundos en tu vida.';

  @override
  String get guideSageExpertise =>
      'Perspectiva espiritual profunda, patrones kármicos y reconexión con el propósito superior';

  @override
  String get guideHealerName => 'Lyra';

  @override
  String get guideHealerTitle => 'La Sanadora Compasiva';

  @override
  String get guideHealerDescription =>
      'Una guía gentil y nutritiva que ofrece apoyo emocional y sabiduría sanadora, perfecta para momentos cuando necesitas consuelo y autocompasión.';

  @override
  String get guideHealerExpertise =>
      'Sanación emocional, autocuidado, navegación de emociones difíciles y construcción del amor propio';

  @override
  String get guideMentorName => 'Kael';

  @override
  String get guideMentorTitle => 'El Estratega Práctico';

  @override
  String get guideMentorDescription =>
      'Un guía claro y directo que proporciona consejos accionables y soluciones prácticas, ideal para decisiones de carrera y desafíos del mundo real.';

  @override
  String get guideMentorExpertise =>
      'Orientación profesional, decisiones prácticas, planificación estratégica y pasos accionables';

  @override
  String get guideVisionaryName => 'Elara';

  @override
  String get guideVisionaryTitle => 'La Musa Creativa';

  @override
  String get guideVisionaryDescription =>
      'Una guía inspiradora que te ayuda a explorar posibilidades y desbloquear tu potencial creativo, perfecta para superar bloqueos y visualizar nuevos futuros.';

  @override
  String get guideVisionaryExpertise =>
      'Inspiración creativa, exploración de posibilidades, superación de bloqueos y liberación del potencial';
}
