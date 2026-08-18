<?php
/**
 * ═══════════════════════════════════════════════════════════════
 *  Pro Kisan — मंडी भाव API
 *  GET /prokisan_api/api/mandi.php
 *
 *  ऐप (lib/ui/mandi_screen.dart) ठीक इस आकार का JSON पढ़ता है —
 *  key के नाम बदले तो भाव दिखना बंद हो जाएगा:
 *
 *  [
 *    {
 *      "state":      "उत्तर प्रदेश",   ← हिंदी में ही
 *      "district":   "वाराणसी",        ← हिंदी में ही
 *      "mandi":      "वाराणसी",        ← "मंडी" शब्द मत जोड़ना, ऐप ख़ुद जोड़ता है
 *      "commodity":  "गेहूं",          ← हिंदी में ही
 *      "minPrice":   2200,
 *      "maxPrice":   2350,
 *      "modalPrice": 2290,
 *      "msp":        2275             ← 0 = उस फसल पर MSP लागू नहीं
 *    }
 *  ]
 *
 *  वैकल्पिक query params (ऐप अभी नहीं भेजता, पर आगे काम आएँगे):
 *    ?state=उत्तर प्रदेश
 *    ?district=वाराणसी
 *    ?commodity=गेहूं
 *    ?days=3      कितने दिन पुराने भाव तक (डिफ़ॉल्ट 3)
 *    ?limit=500   कितने रिकॉर्ड (डिफ़ॉल्ट 500, ज़्यादा से ज़्यादा 2000)
 * ═══════════════════════════════════════════════════════════════
 */

declare(strict_types=1);

require_once __DIR__ . '/../db.php';   // $pdo देता है (PDO, utf8mb4)

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
// ऐप हर बार ताज़ा माँगता है, पर बीच का कोई proxy 5 मिनट रोक सकता है
header('Cache-Control: public, max-age=300');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

try {
    // ── query params ──────────────────────────────────────────
    $state     = trim($_GET['state']     ?? '');
    $district  = trim($_GET['district']  ?? '');
    $commodity = trim($_GET['commodity'] ?? '');

    $days  = (int) ($_GET['days']  ?? 3);
    $limit = (int) ($_GET['limit'] ?? 500);

    // हद में रखो — कोई ?limit=999999 भेजकर सर्वर न बैठा दे
    if ($days  < 1 || $days  > 30)   $days  = 3;
    if ($limit < 1 || $limit > 2000) $limit = 500;

    // ── क्वेरी ────────────────────────────────────────────────
    $sql = "SELECT state, district, mandi, commodity,
                   min_price, max_price, modal_price, msp, arrival_date
              FROM mandi_rates
             WHERE arrival_date >= DATE_SUB(CURDATE(), INTERVAL :days DAY)";

    $params = [':days' => $days];

    if ($state !== '')     { $sql .= " AND state = :state";         $params[':state'] = $state; }
    if ($district !== '')  { $sql .= " AND district = :district";   $params[':district'] = $district; }
    if ($commodity !== '') { $sql .= " AND commodity = :commodity"; $params[':commodity'] = $commodity; }

    // नई तारीख़ पहले, फिर राज्य-ज़िला-फसल के क्रम में
    $sql .= " ORDER BY arrival_date DESC, state, district, commodity
              LIMIT :limit";

    $stmt = $pdo->prepare($sql);
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v, is_int($v) ? PDO::PARAM_INT : PDO::PARAM_STR);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();

    // ── ऐप के आकार में ढालो ───────────────────────────────────
    $out = [];
    while ($r = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $out[] = [
            'state'      => $r['state'],
            'district'   => $r['district'],
            'mandi'      => $r['mandi'],
            'commodity'  => $r['commodity'],
            'minPrice'   => (float) $r['min_price'],
            'maxPrice'   => (float) $r['max_price'],
            'modalPrice' => (float) $r['modal_price'],
            'msp'        => (float) $r['msp'],
            // भाव किस तारीख़ का है — ऐप हर कार्ड पर दिखाता है।
            // ISO (yyyy-MM-dd) भेजते हैं ताकि ऐप उसे आसानी से parse कर सके।
            'date'       => $r['arrival_date'],
        ];
    }

    http_response_code(200);
    echo json_encode($out, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

} catch (Throwable $e) {
    // ⚠️ असली गड़बड़ी का ब्योरा किसान को मत दिखाओ — log में जाए
    error_log('[mandi.php] ' . $e->getMessage());

    http_response_code(500);
    // ऐप खाली सूची पर टूटता नहीं, अपने नमूना भाव दिखाता रहता है
    echo json_encode([], JSON_UNESCAPED_UNICODE);
}
