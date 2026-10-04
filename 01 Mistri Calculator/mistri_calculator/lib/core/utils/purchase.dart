/// Materials are bought whole — nobody sells 7.3 bags of cement.
///
/// Rounds a calculated quantity up to the next whole unit. The tiny tolerance
/// keeps a floating-point 8.0000001 from turning into 9.
int roundUpToBuy(double quantity) {
  if (quantity <= 0) return 0;
  return (quantity - 1e-6).ceil();
}
