#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * LottoAnalyzerHelper – Hilfsklasse für die Lotto-Nummernziehung.
 *
 * ACHTUNG: Diese Datei enthält ABSICHTLICHE Fehler, die der Clang Static Analyzer
 * erkennen soll:
 *   1. Memory Leak   – malloc-Puffer wird nie freigegeben  (unix.Malloc)
 *   2. Null Dereference – Zeiger ohne NULL-Check dereferenziert (core.NullDereference)
 *   3. Dead Store    – Zuweisung, deren Wert nie gelesen wird  (deadcode.DeadStores)
 *
 * Die App läuft trotzdem, weil die kritischen Pfade zur Laufzeit nie den
 * problematischen Branch betreten.
 */
@interface LottoAnalyzerHelper : NSObject

/// Zieht 6 Lottozahlen (1–49), sortiert aufsteigend.
/// BUG #1: Interner malloc-Puffer wird nie freigegeben → Memory Leak.
+ (NSArray<NSNumber *> *)generateLottoNumbers;

/// Formatiert ein Zahlen-Array zu einem lesbaren String.
/// BUG #2: separator-Zeiger kann NULL sein, wird aber ohne Guard genutzt.
+ (NSString *)formatNumbers:(NSArray<NSNumber *> *)numbers
              withSeparator:(nullable NSString *)separator;

/// Berechnet einen Multiplikator für den Gewinnfall.
/// BUG #3: Dead Store – erste Zuweisung wird überschrieben, bevor sie gelesen wird.
///         Unreachable Code – Code nach einem vollständigen return-Pfad.
+ (int)computeMultiplier:(BOOL)useSpecial;

@end

NS_ASSUME_NONNULL_END
