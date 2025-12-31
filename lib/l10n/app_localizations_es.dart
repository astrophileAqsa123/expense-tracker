// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settings => 'Configuración';

  @override
  String get general => 'GENERAL';

  @override
  String get account => 'Cuenta';

  @override
  String get accountSubtitle => 'Perfil, contraseña';

  @override
  String get language => 'Idioma';

  @override
  String get currency => 'Moneda';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get appearance => 'APARIENCIA';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get budgetFeatures => 'FUNCIONES DE PRESUPUESTO';

  @override
  String get advancedBudgetSetup => 'Configuración avanzada de presupuesto';

  @override
  String get advancedBudgetSubtitle => 'Predicciones con IA y auto-categoría';

  @override
  String get security => 'SEGURIDAD';

  @override
  String get privacySecurity => 'Privacidad y seguridad';

  @override
  String get privacySecuritySubtitle => 'Bloqueo de app, permisos';

  @override
  String get about => 'ACERCA DE';

  @override
  String get aboutApp => 'Acerca de la app';

  @override
  String get dashboard => 'Panel';

  @override
  String get analytics => 'Analíticas';

  @override
  String get analysis => 'Análisis';

  @override
  String get graphs => 'Gráficos';

  @override
  String get graph => 'Gráfico';

  @override
  String get charts => 'Diagramas';

  @override
  String get chart => 'Diagrama';

  @override
  String get spendingTrends => 'Tendencias de gasto';

  @override
  String get incomeVsExpense => 'Ingresos vs gastos';

  @override
  String get categoryBreakdown => 'Desglose por categoría';

  @override
  String get overview => 'Resumen';

  @override
  String get report => 'Reporte';

  @override
  String get exportReport => 'Exportar reporte';

  @override
  String get noData => 'No hay datos disponibles';

  @override
  String get selectRange => 'Seleccionar rango';

  @override
  String get filter => 'Filtrar';

  @override
  String get reset => 'Restablecer';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get userNotLoggedIn =>
      'Usuario no conectado. Inicia sesión para ver el panel.';

  @override
  String get user => 'Usuario';

  @override
  String get loading => 'Cargando...';

  @override
  String get welcomeBack => 'Bienvenido de nuevo,';

  @override
  String get downloadPdfReport => 'Descargar informe PDF';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get permissionDeniedTitle => 'Permiso denegado';

  @override
  String permissionDeniedMessage(Object userId) {
    return 'Revisa tus reglas de seguridad de Firebase Firestore (users/$userId).';
  }

  @override
  String get errorLoadingBalance => 'Error al cargar el balance';

  @override
  String get balanceDataMissingTitle => 'Faltan datos de balance';

  @override
  String balanceDataMissingMessage(Object userId) {
    return 'Asegúrate de que exista un documento en users/$userId y que contenga el campo balance (map).';
  }

  @override
  String errorLoadingStatsPermissionDenied(Object transactionId) {
    return 'Error al cargar estadísticas (Permission Denied). Revisa las reglas para transactions/$transactionId.';
  }

  @override
  String get totalBalance => 'Balance total';

  @override
  String get income => 'Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get expense => 'Gasto';

  @override
  String get savings => 'Ahorros';

  @override
  String get transactions => 'Transacciones';

  @override
  String get categories => 'Categorías';

  @override
  String get pendingBills => 'Facturas pendientes';

  @override
  String get spendingOverview => 'Resumen de gastos';

  @override
  String get errorLoadingChartData => 'Error al cargar datos del gráfico.';

  @override
  String get noExpenseDataAvailable => 'No hay datos de gastos';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get errorLoadingTransactions => 'Error al cargar transacciones';

  @override
  String get noTransactionsYet => 'Aún no hay transacciones';

  @override
  String get transaction => 'Transacción';

  @override
  String get yourBudgets => 'Tus presupuestos';

  @override
  String get addExpense => 'Agregar gasto';

  @override
  String get addIncome => 'Agregar ingreso';

  @override
  String get scanReceipt => 'Escanear recibo';

  @override
  String get title => 'Título';

  @override
  String get amount => 'Monto';

  @override
  String get category => 'Categoría';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get enterTitle => 'Ingresa un título';

  @override
  String get enterAmount => 'Ingresa un monto';

  @override
  String get invalidNumber => 'Número inválido';

  @override
  String get amountMustBeGreaterThanZero => 'El monto debe ser > 0';

  @override
  String get expenseFailedTitle => 'Gasto fallido';

  @override
  String expenseOverBalanceMessage(
    Object balance,
    Object expense,
    Object diff,
  ) {
    return 'Tu gasto es mayor que tu balance disponible.\n\nBalance disponible: $balance\nGasto: $expense\nFalta: $diff\n\nReduce el gasto o agrega ingresos primero.';
  }

  @override
  String get ok => 'OK';

  @override
  String get expenseAddedSuccessfully => 'Gasto agregado correctamente';

  @override
  String get failedToAddExpense => 'No se pudo agregar el gasto';

  @override
  String get incomeAddedSuccessfully => '¡Ingreso agregado correctamente!';

  @override
  String get failedToAddIncome => 'No se pudo agregar el ingreso';

  @override
  String get food => 'Comida';

  @override
  String get transport => 'Transporte';

  @override
  String get shopping => 'Compras';

  @override
  String get bills => 'Facturas';

  @override
  String get entertainment => 'Entretenimiento';

  @override
  String get health => 'Salud';

  @override
  String get education => 'Educación';

  @override
  String get other => 'Otro';

  @override
  String get rent => 'Alquiler';

  @override
  String get travel => 'Viaje';

  @override
  String get salary => 'Salario';

  @override
  String get freelance => 'Freelance';

  @override
  String get business => 'Negocio';

  @override
  String get bonus => 'Bono';

  @override
  String get gift => 'Regalo';

  @override
  String get expenseByCategory => 'Gasto por categoría';

  @override
  String get dailyExpenseTrend => 'Tendencia diaria de gastos';

  @override
  String get netSavings => 'Ahorro neto';

  @override
  String get noDailyExpenseData => 'No hay datos diarios de gasto.';

  @override
  String get dayOfMonth => 'Día del mes';

  @override
  String get need => 'Necesidad';

  @override
  String get want => 'Deseo';

  @override
  String get saving => 'Ahorro';

  @override
  String get notEnoughPastData =>
      '¡No hay suficientes datos anteriores para predecir!';

  @override
  String predictedUsing(Object count) {
    return 'Predicho usando los últimos $count presupuestos';
  }

  @override
  String errorPredicting(Object error) {
    return 'Error al predecir: $error';
  }

  @override
  String get budgetSavedSuccessfully => '¡Presupuesto guardado con éxito!';

  @override
  String get dynamicBudgetsTitle =>
      'Presupuestos dinámicos (autoajuste según el balance)';

  @override
  String get auto => 'Auto';

  @override
  String get predictFromHistory => 'Predecir desde el historial';

  @override
  String get overBudgetReduce => '¡Fuera de presupuesto! Reduce el gasto';

  @override
  String get applyAndSaveBudget => 'Aplicar y guardar presupuesto';

  @override
  String get balanceIsZeroHint =>
      'El balance total del panel es 0. Agrega ingresos para obtener recomendaciones.';

  @override
  String usingDashboardBalanceHint(Object uid) {
    return 'Usando el balance total del panel (users/$uid.balance.totalBalance) y aplicando 50/30/20 con recomendaciones por categoría.';
  }

  @override
  String totalBalanceDashboard(Object currency, Object amount) {
    return 'Balance total (Panel): $currency $amount';
  }

  @override
  String needsTarget(Object amount) {
    return 'Necesidades (Objetivo: $amount)';
  }

  @override
  String wantsTarget(Object amount) {
    return 'Deseos (Objetivo: $amount)';
  }

  @override
  String savingsTarget(Object amount) {
    return 'Ahorro (Objetivo: $amount)';
  }

  @override
  String get budgetDocNotFound =>
      'Error: No se encontró el documento de presupuesto para editar.';

  @override
  String editingBudget(Object periodKey) {
    return 'Editando presupuesto: $periodKey';
  }

  @override
  String get enterAtLeastOneCategoryBudget =>
      'Ingresa al menos un presupuesto de categoría';

  @override
  String get budgetAlreadyExistsLoadToEdit =>
      'Ya existe un presupuesto para este período. Cárgalo para editar.';

  @override
  String get budgetUpdated => 'Presupuesto actualizado';

  @override
  String get budgetCreated => 'Presupuesto creado';

  @override
  String get budgetDeleted => 'Presupuesto eliminado';

  @override
  String get editBudget => 'Editar presupuesto';

  @override
  String get setBudget => 'Establecer presupuesto';

  @override
  String get categoryBudgets => 'Presupuestos por categoría';

  @override
  String get updateBudget => 'Actualizar presupuesto';

  @override
  String get saveBudget => 'Guardar presupuesto';

  @override
  String get deleteBudget => 'Eliminar presupuesto';

  @override
  String get viewEditOldBudgets => 'Ver/Editar presupuestos antiguos';

  @override
  String get budgetPeriod => 'Período del presupuesto';

  @override
  String get daily => 'Diario';

  @override
  String get customDays => 'Días personalizados';

  @override
  String get numberOfDays => 'Número de días';

  @override
  String get currencyPrefix => 'Rs ';

  @override
  String get budgetDeletedSuccessfully => '¡Presupuesto eliminado con éxito!';

  @override
  String failedToDeleteBudget(Object error) {
    return 'No se pudo eliminar el presupuesto: $error';
  }

  @override
  String get confirmDeletion => 'Confirmar eliminación';

  @override
  String confirmDeleteBudgetMessage(Object periodKey) {
    return '¿Seguro que deseas eliminar el presupuesto de $periodKey? Esta acción no se puede deshacer.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String editBudgetPlaceholder(Object periodKey) {
    return 'Implementando edición para el presupuesto $periodKey. Normalmente navegarías a un formulario aquí.';
  }

  @override
  String get noBudgetsFound => 'No se encontraron presupuestos';

  @override
  String get createFirstBudgetHint =>
      'Crea tu primer presupuesto para comenzar.';

  @override
  String get edit => 'Editar';

  @override
  String get total => 'Total';

  @override
  String get tapToApplyBudget => 'Toca para aplicar este presupuesto';
}
