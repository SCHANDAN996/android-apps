# -*- coding: utf-8 -*-
"""गोपनीयता नीति को Blogger में चिपकाने लायक़ बनाओ।

नीति की असली जगह `app/play_store_assets/privacy_policy.html` है — वो
अपने आप में पूरी फ़ाइल है (अपनी CSS समेत), ताकि किसी भी ब्राउज़र में
सीधे खुल जाए।

Blogger की पोस्ट में वो पूरी फ़ाइल नहीं चिपकाई जा सकती — वहाँ सिर्फ़
पोस्ट का अंदरूनी हिस्सा जाता है, और `<style>` पर भरोसा नहीं (theme उसे
हटा भी सकती है)। इसलिए यह script वही नीति लेकर:

  - `<body>`, `<main>`, `<div>` जैसे ढाँचे वाले टैग हटा देती है
  - `class` हटाकर तालिका को अपनी लकीरें दे देती है
  - `<h1>` हटा देती है — Blogger पोस्ट का शीर्षक ख़ुद देता है

⚠ नीति बदलनी हो तो **पहले असली फ़ाइल बदलिए**, फिर यह चलाइए। उल्टा किया
तो दोनों अलग-अलग बात कहने लगेंगी, और Play का reviewer वही पढ़ेगा जो
Blogger पर है।

    python tools/banao_blogger_niti.py
"""
import os
import re

YAHAN = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASLI = os.path.join(YAHAN, 'app', 'play_store_assets', 'privacy_policy.html')
BANEGI = os.path.join(YAHAN, 'app', 'play_store_assets',
                      'privacy_policy_blogger.html')

UPAR = """<!--
  विधिवत — गोपनीयता नीति, Blogger में चिपकाने के लिए।

  कैसे चढ़ाएँ:
    1. Blogger → नई पोस्ट
    2. शीर्षक: विधिवत — गोपनीयता नीति / Vidhivat Privacy Policy
    3. ऊपर बाएँ "Compose" की जगह "HTML view" चुनिए
    4. नीचे का सब कुछ वहाँ चिपकाइए, फिर Publish
    5. जो पता मिले वही Play Console के Privacy policy URL में डालिए

  ⚠ यह फ़ाइल अपने आप बनती है — इसे हाथ से मत बदलिए।
    नीति बदलनी हो तो app/play_store_assets/privacy_policy.html बदलिए,
    फिर: python tools/banao_blogger_niti.py
-->

"""


def banao(html):
    i = html.find('<body>') + len('<body>')
    s = html[i:html.rfind('</body>')]

    for t in ['<main>', '</main>', '<hr>', '<hr/>', '<hr />']:
        s = s.replace(t, '')

    s = re.sub(r'<div class="card">(.*?)</div>', r'<blockquote>\1</blockquote>',
               s, flags=re.S)
    s = re.sub(r'<p class="sub">(.*?)</p>', r'<p><small>\1</small></p>',
               s, flags=re.S)
    # बाक़ी सारे div — Blogger की पोस्ट में इनका कोई काम नहीं
    s = re.sub(r'<div[^>]*>', '', s)
    s = s.replace('</div>', '')
    s = re.sub(r'<(\w+) class="[^"]*"', r'<\1', s)

    # तालिका को अपनी लकीरें — Blogger की theme पर भरोसा नहीं
    s = s.replace('<table>', '<table style="border-collapse:collapse;width:100%">')
    s = s.replace('<th>', '<th style="border:1px solid #999;padding:6px;'
                          'text-align:left">')
    s = s.replace('<td>', '<td style="border:1px solid #999;padding:6px">')

    # पोस्ट का शीर्षक Blogger ख़ुद देता है
    s = re.sub(r'<h1>.*?</h1>\s*', '', s, count=1, flags=re.S)
    s = re.sub(r'<footer>(.*?)</footer>', r'<p><small>\1</small></p>',
               s, flags=re.S)

    return re.sub(r'\n{3,}', '\n\n', s).strip()


if __name__ == '__main__':
    with open(ASLI, encoding='utf-8') as f:
        html = f.read()
    with open(BANEGI, 'w', encoding='utf-8', newline='\n') as f:
        f.write(UPAR + banao(html) + '\n')
    print('बनी: app/play_store_assets/privacy_policy_blogger.html')
