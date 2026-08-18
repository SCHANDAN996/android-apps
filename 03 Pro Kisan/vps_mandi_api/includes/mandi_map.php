<?php
/**
 * ═══════════════════════════════════════════════════════════════
 *  Pro Kisan — अंग्रेज़ी ⇄ हिंदी नामों का नक्शा
 *
 *  ⚠️ नीचे के अंग्रेज़ी नाम **AGMARKNET के असली feed से लिए गए हैं**
 *  (23/07/2026 को 3000 पंक्तियाँ जाँचकर), अंदाज़े से नहीं।
 *  यह ज़रूरी है — feed "Paddy(Common)" कहता है, "Paddy(Dhan)(Common)"
 *  नहीं; "Keralam" कहता है, "Kerala" नहीं; "Chattisgarh" कहता है
 *  (एक 't' कम), "Chhattisgarh" नहीं।
 *  एक अक्षर का फ़र्क़ भी हो तो वह फसल कभी सहेजी ही नहीं जाएगी।
 *
 *  हिंदी नाम ऐप के code (mandi_screen.dart) से मेल खाते हैं — ऐप
 *  हिंदी नामों से ही छाँटता है।
 * ═══════════════════════════════════════════════════════════════
 */

/** AGMARKNET का राज्य → ऐप का हिंदी राज्य */
const STATE_HI = [
    'Uttar Pradesh' => 'उत्तर प्रदेश',
    'Madhya Pradesh' => 'मध्य प्रदेश',
    'Bihar' => 'बिहार',
    'Rajasthan' => 'राजस्थान',
    'Haryana' => 'हरियाणा',
    'Punjab' => 'पंजाब',
    'Maharashtra' => 'महाराष्ट्र',
    'West Bengal' => 'पश्चिम बंगाल',
    'Telangana' => 'तेलंगाना',
    'Andhra Pradesh' => 'आंध्र प्रदेश',
    'Karnataka' => 'कर्नाटक',
    'Tamil Nadu' => 'तमिलनाडु',
    'Gujarat' => 'गुजरात',
    'Chattisgarh' => 'छत्तीसगढ़',
    'Chhattisgarh' => 'छत्तीसगढ़',
    'Jharkhand' => 'झारखंड',
    'Uttarakhand' => 'उत्तराखंड',
    'Keralam' => 'केरल',
    'Kerala' => 'केरल',
    'Odisha' => 'ओडिशा',
    'Assam' => 'असम',
    'Jammu and Kashmir' => 'जम्मू और कश्मीर',
    'Himachal Pradesh' => 'हिमाचल प्रदेश',
    'NCT of Delhi' => 'दिल्ली',
    'Goa' => 'गोवा',
    'Tripura' => 'त्रिपुरा',
    'Manipur' => 'मणिपुर',
    'Meghalaya' => 'मेघालय',
    'Nagaland' => 'नागालैंड',
    'Chandigarh' => 'चंडीगढ़',
    'Andaman and Nicobar' => 'अंडमान और निकोबार',
];

/** AGMARKNET की commodity → हिंदी फसल */
const CROP_HI = [
    'Wheat' => 'गेहूं',
    'Paddy(Common)' => 'धान (Common)',
    'Rice' => 'चावल',
    'Maize' => 'मक्का',
    'Bajra(Pearl Millet/Cumbu)' => 'बाजरा',
    'Jowar(Sorghum)' => 'ज्वार',
    'Barley(Jau)' => 'जौ',
    'Ragi(Finger Millet)' => 'रागी',
    'Bengal Gram(Gram)(Whole)' => 'चना',
    'Gram Raw(Chholia)' => 'हरा चना',
    'Red gram/Arhar/Tur(whole)' => 'अरहर (तूर)',
    'Lentil(Masur)(Whole)' => 'मसूर',
    'Green Gram(Moong)(Whole)' => 'मूंग',
    'Black Gram(Urd Beans)(Whole)' => 'उड़द',
    'Kulthi(Horse Gram)' => 'कुल्थी',
    'Mustard' => 'सरसों',
    'Soyabean' => 'सोयाबीन',
    'Groundnut' => 'मूंगफली',
    'Sesamum(Sesame,Gingelly,Til)' => 'तिल',
    'Cotton' => 'कपास',
    'Turmeric' => 'हल्दी',
    'Black pepper' => 'काली मिर्च',
    'Potato' => 'आलू',
    'Onion' => 'प्याज',
    'Onion Green' => 'हरा प्याज',
    'Tomato' => 'टमाटर',
    'Brinjal' => 'बैंगन',
    'Green Chilli' => 'मिर्च',
    'Bhindi(Ladies Finger)' => 'भिंडी',
    'Cabbage' => 'पत्ता गोभी',
    'Cauliflower' => 'फूलगोभी',
    'Carrot' => 'गाजर',
    'Raddish' => 'मूली',
    'Garlic' => 'लहसुन',
    'Ginger(Green)' => 'अदरक',
    'Coriander(Leaves)' => 'धनिया',
    'Capsicum' => 'शिमला मिर्च',
    'Beetroot' => 'चुकंदर',
    'Pumpkin' => 'कद्दू',
    'Bitter gourd' => 'करेला',
    'Bottle gourd' => 'लौकी',
    'Ridgeguard(Tori)' => 'तोरी',
    'Cucumbar(Kheera)' => 'खीरा',
    'Ashgourd' => 'पेठा',
    'Pointed gourd(Parval)' => 'परवल',
    'Sponge gourd' => 'नेनुआ',
    'Little gourd(Kundru)' => 'कुंदरू',
    'Drumstick' => 'सहजन',
    'Mint(Pudina)' => 'पुदीना',
    'Amaranthus' => 'चौलाई',
    'Turnip' => 'शलजम',
    'Peas Wet' => 'मटर',
    'Green Peas' => 'हरी मटर',
    'Spinach' => 'पालक',
    'Sweet Potato' => 'शकरकंद',
    'Colocosia' => 'अरबी',
    'Yam' => 'जिमीकंद',
    'Banana' => 'केला',
    'Banana - Green' => 'कच्चा केला',
    'Mango' => 'आम',
    'Mango(Raw-Ripe)' => 'कच्चा आम',
    'Papaya' => 'पपीता',
    'Lemon' => 'नींबू',
    'Pomegranate' => 'अनार',
    'Guava' => 'अमरूद',
    'Apple' => 'सेब',
    'Grapes' => 'अंगूर',
    'Orange' => 'संतरा',
    'Coconut' => 'नारियल',
    'Water Melon' => 'तरबूज',
    'Pineapple' => 'अनानास',
];

/** हिंदी फसल → MSP 2024-25 (₹/क्विंटल)। सूची में न हो तो 0 = MSP लागू नहीं */
const MSP = [
    'गेहूं' => '2275',
    'धान (Common)' => '2300',
    'धान (Grade A)' => '2320',
    'मक्का' => '2225',
    'चना' => '5440',
    'सरसों' => '5650',
    'सोयाबीन' => '4892',
    'मूंगफली' => '6377',
    'अरहर (तूर)' => '7000',
    'मसूर' => '6425',
    'बाजरा' => '2625',
    'ज्वार' => '3371',
    'जौ' => '1850',
    'मूंग' => '8558',
    'उड़द' => '6950',
    'रागी' => '4290',
    'तिल' => '8300',
    'कपास' => '7120',
];

/** अंग्रेज़ी नाम को हिंदी में बदलो; न मिले तो जैसा है वैसा लौटा दो */
function to_hi(array $map, string $en): string {
    $en = trim($en);
    if (isset($map[$en])) return $map[$en];
    foreach ($map as $k => $v) {          // स्पेस/केस का फ़र्क़ सह लो
        if (strcasecmp(trim($k), $en) === 0) return $v;
    }
    return $en;
}

/** यह फसल ऐप जानता है या नहीं (न जानता हो तो sync उसे छोड़ देता है) */
function is_known_crop(string $en): bool {
    $en = trim($en);
    if (isset(CROP_HI[$en])) return true;
    foreach (CROP_HI as $k => $v) {
        if (strcasecmp(trim($k), $en) === 0) return true;
    }
    return false;
}

function msp_for(string $cropHi): float {
    return isset(MSP[$cropHi]) ? (float) MSP[$cropHi] : 0.0;
}
