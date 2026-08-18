-- ═══════════════════════════════════════════════════════════════
--  Pro Kisan — sync का हिसाब रखने वाला टेबल
--
--  क्यों चाहिए:
--  data.gov.in **कहीं नहीं बताता** कि वह दिन में किस समय ताज़ा होता है।
--  मंडी के APMC कर्मचारी दिन भर आँकड़े भरते रहते हैं — सुबह की नीलामी
--  6-11 बजे, दूसरा सत्र दोपहर बाद।
--
--  इसलिए cron का सही समय **अंदाज़े से नहीं** तय होगा। हर बार sync चलने पर
--  यहाँ लिख देंगे कि किस समय चलाने पर कौन-सी तारीख़ का भाव मिला। एक हफ़्ते
--  बाद `php cron/when_updates.php` चलाइए — वह नाप कर बता देगा कि असल में
--  किस घंटे नया डेटा आता है।
--
--  चलाने का तरीक़ा:
--    mysql -u prokisan_user -p pro_kisan_db < add_sync_log.sql
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS mandi_sync_log (
  id            INT AUTO_INCREMENT PRIMARY KEY,

  -- sync कब चला (IST)
  ran_at        DATETIME NOT NULL,

  -- उस चक्कर में सबसे नई arrival_date जो मिली
  newest_date   DATE NULL,

  -- कितनी पंक्तियाँ सहेजी गईं
  rows_saved    INT NOT NULL DEFAULT 0,

  -- कितनी अलग-अलग मंडियों का भाव मिला
  mandi_count   INT NOT NULL DEFAULT 0,

  -- चलने में कितने सेकंड लगे
  seconds       INT NOT NULL DEFAULT 0,

  KEY idx_ran (ran_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
