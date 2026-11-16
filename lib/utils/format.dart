// formatea monto ej. 750 -> "750", 750.5 -> "750.50"
String formatExpense(double value) =>
    value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
