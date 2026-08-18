<?php
/**
 * ═══════════════════════════════════════════════════════════════
 *  Pro Kisan — मंडी भाव sync
 *
 *  सरकारी AGMARKNET feed (data.gov.in) से आज के भाव लाकर
 *  mandi_rates टेबल में भर देता है।
 *
 *  चलाने का तरीक़ा (कमांड लाइन से):
 *      php /var/www/prokisan_api/cron/mandi_sync.php
 *
 *  रोज़ अपने आप चलाने के लिए crontab में (सुबह 6 और शाम 6):
 *      0 6,18 * * * /usr/bin/php /var/www/prokisan_api/cron/mandi_sync.php >> /var/log/prokisan_mandi.log 2>&1
 *
 *  ⚠️ यह फ़ाइल ब्राउज़र से नहीं खुलनी चाहिए — नीचे उसकी जाँच है,
 *     और nginx में भी /cron/ को ब्लॉक करना (देखें README)।
 * ═══════════════════════════════════════════════════════════════
 */

declare(strict_types=1);

// सिर्फ़ कमांड लाइन से चले
if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("यह स्क्रिप्ट सिर्फ़ कमांड लाइन से चलती है\n");
}

require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../includes/mandi_map.php';

// ── सेटिंग ────────────────────────────────────────────────────

/**
 * data.gov.in की अपनी API key।
 *
 * नीचे आपकी असली key है — 23/07/2026 को जाँची गई, limit=1000 पर पूरे
 * 1000 रिकॉर्ड देती है।
 *
 * ⚠️ key एक निजी चीज़ है। इसे सार्वजनिक git repo में मत डालना।
 * बेहतर तरीक़ा — फ़ाइल में लिखने के बजाय पर्यावरण चर से देना:
 *   export DATA_GOV_KEY="आपकी-key"
 */
const DEFAULT_KEY = '579b464db66ec23bdd000001bf22cca7d4ba4ba9737cdc8c54b12815';
$API_KEY = getenv('DATA_GOV_KEY') ?: DEFAULT_KEY;

/** AGMARKNET का "Current Daily Price of Various Commodities" resource */
const RESOURCE_ID = '9ef84268-d588-465a-a308-a864a43d0070';

/** एक बार में कितने रिकॉर्ड माँगें (अपनी key पर 1000 तक चलता है) */
const PAGE_SIZE = 1000;

/** एक राज्य के लिए ज़्यादा से ज़्यादा कितने पन्ने खींचें */
const MAX_PAGES_PER_STATE = 5;

/**
 * किन राज्यों का data खींचें।
 *
 * नक्शे में कुछ राज्यों की दो वर्तनियाँ हैं (feed "Chattisgarh" लिखता है,
 * सही वर्तनी "Chhattisgarh" है; इसी तरह "Keralam" / "Kerala")। दोनों रखी
 * हैं ताकि feed चाहे जो भेजे, अनुवाद हो जाए — पर खींचते समय हर राज्य के
 * लिए एक ही बार जाना है, वरना बेकार में दूनी API कॉल होंगी।
 */
$STATES_EN = [];
$seenHi = [];
foreach (STATE_HI as $en => $hi) {
    if (isset($seenHi[$hi])) continue;   // यह राज्य पहले ही सूची में है
    $seenHi[$hi] = true;
    $STATES_EN[] = $en;                  // पहली वर्तनी = feed वाली
}

// ── मुख्य काम ─────────────────────────────────────────────────

$startedAt = microtime(true);
$totalIn = 0;
$totalSaved = 0;
$skippedCrop = 0;
$skippedState = 0;
$unknownStates = [];
$errors = [];

logLine("═══ मंडी sync शुरू — " . date('d/m/Y H:i:s') . " ═══");

$insert = $pdo->prepare(
    "INSERT INTO mandi_rates
        (state, district, mandi, commodity, variety,
         min_price, max_price, modal_price, msp, arrival_date)
     VALUES
        (:state, :district, :mandi, :commodity, :variety,
         :min_price, :max_price, :modal_price, :msp, :arrival_date)
     ON DUPLICATE KEY UPDATE
        min_price   = VALUES(min_price),
        max_price   = VALUES(max_price),
        modal_price = VALUES(modal_price),
        msp         = VALUES(msp)"
);

foreach ($STATES_EN as $stateEn) {
    // सिर्फ़ log में दिखाने के लिए — असली राज्य हर पंक्ति से पढ़ा जाता है
    $stateHi = STATE_HI[$stateEn];
    $savedForState = 0;

    for ($page = 0; $page < MAX_PAGES_PER_STATE; $page++) {
        $offset = $page * PAGE_SIZE;

        $url = 'https://api.data.gov.in/resource/' . RESOURCE_ID
             . '?api-key=' . urlencode($API_KEY)
             . '&format=json'
             . '&limit=' . PAGE_SIZE
             . '&offset=' . $offset
             . '&filters%5Bstate%5D=' . urlencode($stateEn);

        $json = httpGet($url);
        if ($json === null) {
            $errors[] = "$stateEn: पन्ना $page नहीं मिला";
            break;
        }

        $data = json_decode($json, true);
        $records = $data['records'] ?? [];
        if (!$records) break;   // इस राज्य का data ख़त्म

        $totalIn += count($records);

        $pdo->beginTransaction();
        try {
            foreach ($records as $rec) {
                // ⚠️ राज्य **हर पंक्ति से ही** पढ़ो, यह मत मानो कि जो राज्य
                // माँगा था वही आया है।
                //
                // data.gov.in का filters[state] भरोसेमंद नहीं है — जाँच में
                // "Andaman and Nicobar" माँगने पर 110 पंक्तियाँ आईं जिनमें
                // 93 जम्मू-कश्मीर की थीं। पहले यहाँ माँगा हुआ राज्य ($stateHi)
                // सब पंक्तियों पर चिपका दिया जाता था, इसलिए कश्मीर के सेब
                // "अंडमान" के नाम से सहेजे जा रहे थे।
                $rowStateEn = trim((string) ($rec['state'] ?? ''));
                if ($rowStateEn === '') continue;

                $rowStateHi = to_hi(STATE_HI, $rowStateEn);
                // नक्शे में न हो तो छोड़ दो — वरना अंग्रेज़ी नाम टेबल में घुसेगा
                // और ऐप के हिंदी फ़िल्टर से कभी मेल नहीं खाएगा
                if ($rowStateHi === $rowStateEn) {
                    $skippedState++;
                    $unknownStates[$rowStateEn] = true;
                    continue;
                }

                $cropEn = trim((string) ($rec['commodity'] ?? ''));

                // जो फसल हमारे नक्शे में नहीं, उसे मत भरो — वरना टेबल में
                // हज़ारों बेकार पंक्तियाँ (लकड़ी, फूल, चारा…) जमा हो जाएँगी
                if (!is_known_crop($cropEn)) {
                    $skippedCrop++;
                    continue;
                }
                $cropHi = to_hi(CROP_HI, $cropEn);

                $date = parseDate((string) ($rec['arrival_date'] ?? ''));
                if ($date === null) continue;

                $insert->execute([
                    ':state'        => $rowStateHi,
                    ':district'     => trim((string) ($rec['district'] ?? '')),
                    // ऐप ख़ुद " मंडी" जोड़ता है, इसलिए यहाँ सिर्फ़ नाम
                    ':mandi'        => trim((string) ($rec['market'] ?? $rec['district'] ?? '')),
                    ':commodity'    => $cropHi,
                    ':variety'      => trim((string) ($rec['variety'] ?? '')),
                    ':min_price'    => toPrice($rec['min_price']   ?? 0),
                    ':max_price'    => toPrice($rec['max_price']   ?? 0),
                    ':modal_price'  => toPrice($rec['modal_price'] ?? 0),
                    ':msp'          => msp_for($cropHi),
                    ':arrival_date' => $date,
                ]);
                $savedForState++;
                $totalSaved++;
            }
            $pdo->commit();
        } catch (Throwable $e) {
            $pdo->rollBack();
            $errors[] = "$stateEn: " . $e->getMessage();
            break;
        }

        // इस पन्ने में पूरा भरा नहीं आया → और पन्ने नहीं हैं
        if (count($records) < PAGE_SIZE) break;

        // सरकारी सर्वर पर दया करो
        usleep(300000);   // 0.3 सेकंड
    }

    logLine(sprintf('  %-20s %5d भाव', $stateHi, $savedForState));
}

// ── पुरानी पंक्तियाँ हटाओ ─────────────────────────────────────
// 30 दिन से पुराने भाव किसी काम के नहीं, और टेबल हल्की रहती है
$deleted = $pdo->exec(
    "DELETE FROM mandi_rates
      WHERE arrival_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY)"
);

// ── सारांश ────────────────────────────────────────────────────
$secs = round(microtime(true) - $startedAt, 1);
logLine("───────────────────────────────────────");
logLine("आए        : $totalIn");
logLine("सहेजे     : $totalSaved");
logLine("छोड़े (फसल): $skippedCrop (नक्शे में वह फसल नहीं)");
logLine("छोड़े (राज्य): $skippedState (नक्शे में वह राज्य नहीं)");
logLine("पुराने हटे: " . (int) $deleted);
logLine("समय       : {$secs}s");
if ($errors) {
    logLine("गड़बड़ियाँ :");
    foreach (array_slice($errors, 0, 10) as $e) logLine("  • $e");
}
logLine("═══ पूरा ═══\n");

exit($totalSaved > 0 ? 0 : 1);


// ── सहायक ─────────────────────────────────────────────────────

function httpGet(string $url): ?string {
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT        => 40,
        CURLOPT_CONNECTTIMEOUT => 15,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_USERAGENT      => 'ProKisan/1.0 (+mandi sync)',
    ]);
    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err  = curl_error($ch);
    curl_close($ch);

    if ($body === false || $code !== 200) {
        error_log("[mandi_sync] HTTP $code $err — $url");
        return null;
    }
    return (string) $body;
}

/** AGMARKNET की तारीख़ "23/07/2026" → MySQL की "2026-07-23" */
function parseDate(string $s): ?string {
    $s = trim($s);
    if ($s === '') return null;
    $d = DateTime::createFromFormat('d/m/Y', $s);
    if ($d === false) {
        $d = DateTime::createFromFormat('Y-m-d', $s);
    }
    return $d ? $d->format('Y-m-d') : null;
}

/** भाव को संख्या में — feed में कभी "2469.61", कभी "NR" या खाली आता है */
function toPrice($v): float {
    if (is_numeric($v)) return (float) $v;
    $clean = preg_replace('/[^0-9.]/', '', (string) $v);
    return $clean === '' ? 0.0 : (float) $clean;
}

function logLine(string $msg): void {
    echo $msg . PHP_EOL;
}
