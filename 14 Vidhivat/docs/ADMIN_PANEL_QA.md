# Admin Panel — पहले संस्करण की जाँच

25 अक्टूबर2026। उपयोगकर्ता: कंटेंट और ऐप प्रबंधन; निर्माण का स्पष्ट निर्देश «करो»।

## तैयार और चल रहा

- Pure Dart local executable: `admin/build/vidhivat-admin.exe`,7,111,680bytes। Windows Flutter native compiler के जरूरी C++ components अधूरे होने से local-browser रास्ता अपनाया; कोई toolchain install या hosting नहीं।
- Root `Open Admin Panel.cmd`, `admin/Start-Admin.ps1` और graceful `Stop-Admin.ps1`। Hidden server launch, running workspace reuse और stop/restart जाँचा। वर्तमान session का पता `admin/.runtime/session.json` में है; token वहाँ नहीं है।
-271 वास्तविक content JSON files,147 app images,135 mapped source-backed files (इस snapshot पर)। Images के exact hashes अलग मिले। ये फ़ाइल/संदर्भ संख्याएँ हैं, verified ग्रंथों या खुले दोषों की संख्या नहीं।

## स्वचालित जाँच

27 tests pass, `dart analyze` no issues, `node --check admin/web/app.js` exit0। Raw final run `admin/verification/tests.log` और fingerprint metadata `test-run.json` में।

जाँचे cases: correct workspace marker, inventory/generated ownership, Hindi aliases, original untouched draft save, stale base hash409, retained draft conflict, generated JSON edit rejection, canonical text draft, invalid/identity-breaking JSON, outside/traversal/backslash paths, historical log labelling, inputs-hash freshness, Host/Origin/session-token guard और unknown command rejection।

पुराने आरती txt में9 खाली comment-only templates मिले; उन्हें canonical input मानने की प्रारम्भिक admin गलती development में सुधारी।2 populated txt के लिए source adapter रखा। दोनों स्थितियों के tests हैं। यह मोबाइल ऐप में नया दोष नहीं था।

## Browser में वास्तव में जाँचा

1. Dashboard live inventory से खुला।
2. गणेश आरती: preview, canonical JSON editor और source-note-only draft save। Reload के बाद draft मौजूद; before/after review और base-hash-same label मिला।
3. Original `app/assets/paath/ganesh_aarti.json` का SHA256 save से पहले/बाद **80AA30A253780B0DEFDDC4065AF9CFFCA25A056CF978D2767A0EDC7A8D6DE4FE** वही रहा। Canonical धार्मिक पाठ/अर्थ नहीं बदले।
4. «गीता» से सभी18 अध्याय search result में आए; पहले16 और अगले पन्ने पर17/18 देखे। अन्य सामग्री में भी वही शब्द होने से global search कुल25matches था; उसे18कुल न बताया।
5. Image search «हनुमान चालीसा» और full detail/name/size/hash/reference खुला।
6. Source register `JAANCH_SAMASYA_PANJI.md` वास्तव में खुला; plain-record viewer है, नये source verification का दावा नहीं।
7. Panel button से वास्तविक admin test process चला। पहले26pass; Hindi-alias test जोड़ने के बाद अंतिम27pass UI से चला। Hash बदलने पर पहले की green report stale/«पुरानी जाँच», अंतिम run समान inputs/«पास» दिखा।
8. Browser startup पर बहुत जल्दी search भरने से दो loading-order exceptions मिलीं; initial snapshot guards जोड़कर वही early-input scenario दोबारा जाँचा। अंतिम audit window में console errors0 मिले।

UI screenshot `admin/screenshots/overview.png` उपलब्ध narrow in-app viewport का है। Responsive desktop CSS मौजूद है, लेकिन इस run में full-width desktop screenshot/physical phone QA नहीं किया। Draft download control बना है; native download-dialog flow अलग नहीं चलाया। Existing browser tabs/user data नहीं मिटाये।

## जानबूझकर अगले चरण

मूल फ़ाइल पर reviewed apply/backup/restore, scan-page तुलना, अधिक typed editors, image assignment/export, home reordering और app build/release publishing अभी नहीं जुड़े। इस पहले संस्करण से drafts ही अलग सहेजते हैं। Source verification अपने आप नहीं होती। User profiles, जन्म-विवरण, केंद्रीय usage/payment tracking इस local content panel में नहीं हैं।

अलग mobile app/engine/canonical assets अपरिवर्तित हैं; उनके पहले2077pass को इस नये panel की27tests में नहीं जोड़ा। कोई commit/push/deployment नहीं किया।

## v0.2 का वास्तविक सत्यापन —25 अक्टूबर 2026

यह नीचे की नई स्थिति ऊपर के v0.1 «अगले चरण» को reviewed apply/backup/restore के लिए supersede करती है।

- `dart test --concurrency=2`: **57/57 pass**, raw `admin/verification/apply-tests.log`; `dart analyze`: **No issues found**, raw `apply-analyze.log`; `node --check web/app.js` exit0। नया Dart executable compile सफल; पुराना server सुरक्षित बन्द करके v0.2 launcher से खोला, दूसरी बार वही live URL reuse हुआ।
- App के असली parsers से पूजा/पाठ/व्रत/पर्व/कथा तथा generated ग्रंथ के payload जाँचे। Source staging में actual sukta और populated राम आरती generator प्रयोग हुए। अलग fixture में existing QA अर्थ जोड़कर verse बदलाव से अर्थ खोने का specifically `arth` guard test पास हुआ।
- Safety cases: no-op draft, base/plan/draft/input/model change, added generated file, preexisting output drift, source identity/schema/खंड संख्या, duplicate/missing source attestation, concurrent lock, mid-write failure rollback, crash partial receipt, external edits preserved, interrupted restore recovery, corrupt backup visible/new prepare blocked, HTTP token and explicit restore confirmation। Automated full tests केवल fixtures/temp में apply करते हैं।
- Browser QA: `admin/.workspace/qa-project` में गणेश पूजा की copied फ़ाइल; परिचय बदला, source-note में QA लिखा, मिलान तैयार हुआ, अधूरे review पर apply disabled मिला। दो स्पष्ट fake QA पुस्तक entries और simulated inspected flags केवल isolated form validation के लिए भरे; वास्तविक छपी पुस्तक पढ़ने का दावा नहीं। Apply से fixture परिचय वास्तव में बदला और backup record खुला; review checkbox के बाद restore से byte-exact original लौटा। Fixture browser console error log खाली था। Full-width 1280×720 screenshot `admin/screenshots/apply-restore-qa.png` में वापस लिया record दिखता है। यह v0.1 की केवल narrow screenshot सीमा से आगे नया प्रमाण है।
- Real workspace का पुराना source-note-only आरती draft prepare पर «मूल पाठ और ड्राफ़्ट समान हैं; लागू करने की जरूरत नहीं है» कहकर रुका। Main workspace में कोई apply/backup नहीं बना। यही intentional guard HTTP400 लौटाता है; इसे अप्रत्याशित console failure न गिनें।
- असली गणेश पूजा SHA256 पहले/बाद `81A3BFCC22349F47F0448A018784F697A586CC4CDA351E40894FD301BD03696B`; restored fixture भी वही। असली गणेश आरती SHA256 `80AA30A253780B0DEFDDC4065AF9CFFCA25A056CF978D2767A0EDC7A8D6DE4FE` वही। Machine evidence `admin/verification/apply-qa.json`।

नई app/engine tests नहीं चलायीं क्योंकि इस चरण में app/engine code/canonical content नहीं बदले। पहले2077 को नयी57 panel tests में नहीं जोड़ा। फोन पर नया APK नहीं बनाया/इंस्टॉल किया। Source attestations मालिक के दर्ज विवरण हैं, panel उनके सत्य होने को प्रमाणित नहीं करता। Staging/current-generation mismatch पर रोक होने से किसी दूसरी content corpus में drift पहले अलग स्रोत-समीक्षा से ठीक करना होगा।
