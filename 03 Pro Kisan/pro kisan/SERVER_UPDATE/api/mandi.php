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
 *      "msp":        2275,            ← 0 = उस फसल पर MSP लागू नहीं
 *      "date":       "2026-08-02",   ← मंडी में सौदा किस दिन हुआ
 *      "fetchedAt":  "2026-08-03 18:04"  ← हमने वह भाव कब उठाया (IST)
 *    }
 *  ]
 *
 *  ⚠️ "date" पहले भेजा ही नहीं जाता था। DB से पढ़ा जाता था पर JSON में
 *     डाला नहीं जाता था — इसलिए ऐप में "📅 भाव इस तारीख़ तक के" वाली पट्टी
 *     कभी नहीं दिखती थी। किसान को पता ही नहीं चलता था कि भाव आज का है या
 *     तीन दिन पुराना।
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

// ⚠️ सर्वर UTC पर हो सकता है। किसान को भारतीय समय ही चाहिए, इसलिए यहीं
// तय कर देते हैं — वरना "शाम 6 बजे" की जगह "दोपहर 12:30" दिखेगा।
date_default_timezone_set('Asia/Kolkata');

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

    // ⚠️ पहले 3 था। कई मंडियाँ हफ़्ते में 2-3 दिन ही खुलती हैं और
    // data.gov.in भी देर से भरता है — 3 दिन में कई ज़िले ख़ाली दिखते थे।
    $days  = (int) ($_GET['days']  ?? 7);
    // ⚠️ पहले 500 था। 20 राज्य × 35 फ़सल में 500 पंक्तियाँ बहुत कम पड़ती
    // हैं — किसान अपना ज़िला चुनता और सूची ख़ाली मिलती।
    $limit = (int) ($_GET['limit'] ?? 2000);

    // हद में रखो — कोई ?limit=999999 भेजकर सर्वर न बैठा दे
    if ($days  < 1 || $days  > 30)   $days  = 7;
    if ($limit < 1 || $limit > 3000) $limit = 2000;

    // ── क्वेरी ────────────────────────────────────────────────
    $sql = "SELECT state, district, mandi, commodity,
                   min_price, max_price, modal_price, msp,
                   arrival_date, updated_at
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

            // मंडी में सौदा किस दिन हुआ — ऐप इसी से "भाव इस तारीख़ तक के"
            // और "(आज) / (कल) / (3 दिन पुराना)" दिखाता है
            'date'       => (string) $r['arrival_date'],

            // हमारे सर्वर ने वह भाव कब उठाया (sync कब चला)।
            // यह तारीख़ से अलग चीज़ है — दोनों दिखाना ज़रूरी है, वरना
            // 3 दिन पुराना भाव ताज़ा लग सकता है।
            // ⚠️ MySQL `updated_at` को **UTC में** सहेजता है (सर्वर UTC पर है
            // और MySQL का time_zone = SYSTEM)। PHP का समय-क्षेत्र IST कर दिया
            // है, इसलिए अगर सीधे strtotime() करें तो वह उस समय को IST मान
            // लेगा और 5:30 घंटे पीछे दिखेगा — किसान को "रात 1 बजे" दिखता,
            // जबकि असल में सुबह 6:43 था।
            // इसलिए साफ़ लिखते हैं कि यह UTC है; strtotime खुद IST में बदल देगा।
            'fetchedAt'  => $r['updated_at']
                ? date('Y-m-d H:i', strtotime((string) $r['updated_at'] . ' UTC'))
                : '',
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
