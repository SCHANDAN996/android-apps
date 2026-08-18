-- ═══════════════════════════════════════════════════════════════
--  Pro Kisan — मंडी भाव का टेबल
--  MySQL 8.0 · pro_kisan_db
--
--  चलाने का तरीक़ा:
--    mysql -u prokisan_user -p pro_kisan_db < mandi_schema.sql
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS mandi_rates (
  id            INT AUTO_INCREMENT PRIMARY KEY,

  -- ⚠️ ये तीनों **हिंदी में** ही रखने हैं। ऐप के फ़िल्टर हिंदी नामों से
  -- मिलान करते हैं (mandi_screen.dart का _stateDistricts), अंग्रेज़ी नाम
  -- भेजने पर भाव दिखेगा तो सही, पर राज्य से छाँटने पर ग़ायब हो जाएगा।
  state         VARCHAR(80)  NOT NULL,
  district      VARCHAR(80)  NOT NULL,

  -- मंडी का नाम — बिना "मंडी" शब्द के। ऐप ख़ुद " मंडी" जोड़ता है।
  mandi         VARCHAR(120) NOT NULL,

  commodity     VARCHAR(100) NOT NULL,
  variety       VARCHAR(80)  DEFAULT '',

  -- ₹ प्रति क्विंटल
  min_price     DECIMAL(10,2) NOT NULL DEFAULT 0,
  max_price     DECIMAL(10,2) NOT NULL DEFAULT 0,
  modal_price   DECIMAL(10,2) NOT NULL DEFAULT 0,

  -- न्यूनतम समर्थन मूल्य — 0 माने उस फसल पर MSP लागू नहीं
  msp           DECIMAL(10,2) NOT NULL DEFAULT 0,

  arrival_date  DATE NOT NULL,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  -- एक ही मंडी + फसल + किस्म + तारीख़ की दोबारा एंट्री न बने।
  -- sync स्क्रिप्ट इसी पर ON DUPLICATE KEY UPDATE करती है।
  UNIQUE KEY uq_rate (state, district, mandi, commodity, variety, arrival_date),

  KEY idx_state_district (state, district),
  KEY idx_commodity (commodity),
  KEY idx_date (arrival_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ── शुरुआती नमूना भाव ────────────────────────────────────────────
-- ताकि sync चलने से पहले भी ऐप को कुछ मिले। sync चलते ही असली भाव
-- इन्हीं पर चढ़ जाएँगे (UNIQUE key की वजह से)।
INSERT IGNORE INTO mandi_rates
  (state, district, mandi, commodity, variety, min_price, max_price, modal_price, msp, arrival_date)
VALUES
  ('उत्तर प्रदेश','वाराणसी','वाराणसी','गेहूं','सामान्य',2200,2350,2290,2275,CURDATE()),
  ('उत्तर प्रदेश','वाराणसी','वाराणसी','धान (Common)','सामान्य',2250,2400,2320,2300,CURDATE()),
  ('उत्तर प्रदेश','लखनऊ','लखनऊ','आलू','सामान्य',800,1500,1100,0,CURDATE()),
  ('उत्तर प्रदेश','कानपुर','कानपुर','सरसों','सामान्य',5500,6200,5800,5650,CURDATE()),
  ('बिहार','पटना','पटना','गेहूं','सामान्य',2180,2320,2260,2275,CURDATE()),
  ('बिहार','पटना','पटना','मक्का','सामान्य',2100,2300,2180,2225,CURDATE()),
  ('मध्य प्रदेश','इंदौर','इंदौर','सोयाबीन','सामान्य',4700,5100,4900,4892,CURDATE()),
  ('मध्य प्रदेश','भोपाल','भोपाल','चना','सामान्य',5200,5800,5500,5440,CURDATE()),
  ('पंजाब','लुधियाना','लुधियाना','गेहूं','सामान्य',2280,2400,2340,2275,CURDATE()),
  ('महाराष्ट्र','पुणे','पुणे','प्याज','सामान्य',1200,2500,1800,0,CURDATE()),
  ('राजस्थान','जयपुर','जयपुर','सरसों','सामान्य',5600,6300,5900,5650,CURDATE()),
  ('हरियाणा','करनाल','करनाल','गेहूं','सामान्य',2260,2380,2310,2275,CURDATE());
