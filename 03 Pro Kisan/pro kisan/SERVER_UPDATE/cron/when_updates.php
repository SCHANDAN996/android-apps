<?php
/**
 * ═══════════════════════════════════════════════════════════════
 *  "असल में किस समय नया भाव आता है?" — नाप कर बताने वाला script
 *
 *  चलाने का तरीक़ा:
 *      php /var/www/prokisan_api/cron/when_updates.php
 *
 *  एक हफ़्ता sync चलने के बाद यह चलाइए। यह `mandi_sync_log` पढ़कर बता देगा
 *  कि दिन के किस समय सबसे ताज़ा भाव मिलता है — फिर उसी हिसाब से cron का
 *  समय कस लीजिए और बेकार के चक्कर बंद कर दीजिए।
 *
 *  ⚠️ यह ज़रूरी क्यों है: data.gov.in कहीं नहीं लिखता कि वह किस समय ताज़ा
 *     होता है। सही समय अंदाज़े से नहीं, **अपने सर्वर पर नापकर** ही पता चलेगा।
 * ═══════════════════════════════════════════════════════════════
 */

declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("यह स्क्रिप्ट सिर्फ़ कमांड लाइन से चलती है\n");
}

require_once __DIR__ . '/../db.php';
date_default_timezone_set('Asia/Kolkata');

try {
    $rows = $pdo->query(
        "SELECT ran_at, newest_date, rows_saved, mandi_count, seconds
           FROM mandi_sync_log
          WHERE ran_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
          ORDER BY ran_at"
    )->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    echo "\nmandi_sync_log टेबल नहीं मिला।\n";
    echo "पहले यह चलाइए:\n";
    echo "  mysql -u prokisan_user -p pro_kisan_db < sql/add_sync_log.sql\n\n";
    exit(1);
}

if (count($rows) < 4) {
    echo "\nअभी बहुत कम हिसाब है (" . count($rows) . " चक्कर)।\n";
    echo "कम से कम 3-4 दिन sync चलने दीजिए, फिर यह चलाइए।\n\n";
    exit(1);
}

// ── घंटे के हिसाब से जोड़ो ────────────────────────────────────────
$byHour = [];
foreach ($rows as $r) {
    $ranTs = strtotime((string) $r['ran_at']);
    if ($ranTs === false || empty($r['newest_date'])) {
        continue;
    }
    $newTs = strtotime((string) $r['newest_date']);

    $hour = (int) date('G', $ranTs);
    // "ताज़गी" = चलाने के दिन और भाव के दिन का फ़र्क़। 0 सबसे अच्छा।
    $lagDays = (int) floor(
        (strtotime(date('Y-m-d', $ranTs)) - $newTs) / 86400
    );

    $byHour[$hour]['lag'][]   = $lagDays;
    $byHour[$hour]['rows'][]  = (int) $r['rows_saved'];
    $byHour[$hour]['mandi'][] = (int) $r['mandi_count'];
}
ksort($byHour);

echo "\nकिस समय चलाने पर कितना ताज़ा भाव मिला\n";
echo str_repeat('═', 64) . "\n";
printf("%-9s %-7s %-15s %-11s %s\n",
    'समय', 'बार', 'ताज़गी (दिन)', 'पंक्तियाँ', 'मंडी');
echo str_repeat('─', 64) . "\n";

$best = null;
foreach ($byHour as $h => $d) {
    $n       = count($d['lag']);
    $avgLag  = array_sum($d['lag']) / $n;
    $avgRows = (int) round(array_sum($d['rows']) / $n);
    $avgMan  = (int) round(array_sum($d['mandi']) / $n);

    printf("%-9s %-7d %-15.1f %-11d %d\n",
        sprintf('%02d:00', $h), $n, $avgLag, $avgRows, $avgMan);

    // सबसे अच्छा = सबसे कम ताज़गी-अंतर; बराबर हो तो ज़्यादा मंडी वाला
    $score = [$avgLag, -$avgMan];
    if ($best === null || $score < $best['score']) {
        $best = ['hour' => $h, 'score' => $score,
                 'lag' => $avgLag, 'mandi' => $avgMan];
    }
}
echo str_repeat('═', 64) . "\n\n";

if ($best !== null) {
    printf("सबसे अच्छा समय: %02d:00 — भाव औसतन %.1f दिन पुराना, %d मंडी\n\n",
        $best['hour'], $best['lag'], $best['mandi']);

    if ($best['lag'] < 0.5) {
        printf("उस घंटे उसी दिन का भाव मिल रहा है। cron में सिर्फ़\n");
        printf("  %02d:15 रखिए और बाक़ी चक्कर हटा दीजिए।\n\n", $best['hour']);
    } else {
        echo "किसी भी समय उसी दिन का भाव नहीं मिल रहा — data.gov.in ख़ुद\n";
        echo "देर से भरता है। यह सामान्य है; ऐप में 'कल का भाव' लिखा आता\n";
        echo "रहेगा, जो सच है।\n\n";
    }
}

// ── पिछले 12 चक्कर ───────────────────────────────────────────────
echo "पिछले चक्कर:\n";
foreach (array_slice($rows, -12) as $r) {
    printf("  %s  →  भाव %s का, %d पंक्ति, %d मंडी, %d सेकंड\n",
        $r['ran_at'], $r['newest_date'] ?: '—',
        (int) $r['rows_saved'], (int) $r['mandi_count'], (int) $r['seconds']);
}
echo "\n";
