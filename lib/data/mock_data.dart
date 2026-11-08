import '../models/grammar_lesson.dart';
import '../models/language.dart';
import '../models/topic.dart';
import '../models/word.dart';

/// Local mock content. Replace with Firestore later by implementing
/// [ContentRepository] — screens never read this file directly.
///
/// Content: 5 languages (English, Arabic and Turkish have full content),
/// 6 topics × 10 words per language, and grammar lessons.
/// Quiz questions are generated from these words by `QuizGenerator`.
abstract final class MockData {
  static const languages = <Language>[
    Language(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      ttsLocale: 'en-US',
    ),
    Language(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
      ttsLocale: 'ar-SA',
    ),
    Language(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
      flag: '🇹🇷',
      ttsLocale: 'tr-TR',
    ),
    Language(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
      ttsLocale: 'fr-FR',
      isAvailable: false,
    ),
    Language(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
      flag: '🇨🇳',
      ttsLocale: 'zh-CN',
      isAvailable: false,
    ),
  ];

  /// Languages that have topic/word content below.
  static const contentLanguages = ['en', 'ar', 'tr'];

  static final List<Topic> topics = [
    for (final lang in contentLanguages)
      for (final seed in _topicSeeds)
        Topic(
          id: '${lang}_${seed.key}',
          languageCode: lang,
          title: seed.title,
          somaliTitle: seed.somaliTitle,
          iconName: seed.key,
          colorValue: seed.color,
          wordCount: seed.words.length,
        ),
  ];

  static final List<Word> words = [
    for (final lang in contentLanguages)
      for (final topic in _topicSeeds)
        for (final w in topic.words)
          Word(
            id: '${lang}_${topic.key}_${w.key}',
            topicId: '${lang}_${topic.key}',
            languageCode: lang,
            text: w.byLang[lang]!.$1,
            phonetic: w.byLang[lang]!.$2,
            example: w.byLang[lang]!.$3,
            translation: w.somali,
            exampleTranslation: w.somaliExample,
            emoji: w.emoji,
          ),
  ];

  static const grammarLessons = <GrammarLesson>[
    // ---------------- English ----------------
    GrammarLesson(
      id: 'en_g1',
      languageCode: 'en',
      order: 1,
      title: 'Personal pronouns',
      description: 'I, you, he, she, it, we, they',
      level: LanguageLevel.beginner,
      explanation:
          'Pronouns replace names so we do not repeat them. In English the '
          'pronoun always comes before the verb. "He" is for a man or boy, '
          '"she" is for a woman or girl, and "it" is for things and animals.',
      rule: 'Subject pronoun + verb\nI · you · he · she · it · we · they',
      examples: [
        GrammarExample('I am a student.', 'Anigu waxaan ahay arday.'),
        GrammarExample('She is my sister.', 'Iyadu waa walaashay.'),
        GrammarExample(
          'We live in Hargeisa.',
          'Annagu waxaan ku noolnahay Hargeysa.',
        ),
        GrammarExample('They are happy.', 'Iyagu way faraxsan yihiin.'),
      ],
      exercise: GrammarExercise(
        prompt: 'Amina is my friend. ___ is a doctor.',
        options: ['He', 'She', 'They'],
        correctIndex: 1,
        explanation: 'Amina is a woman, so we use "she".',
      ),
    ),
    GrammarLesson(
      id: 'en_g2',
      languageCode: 'en',
      order: 2,
      title: 'The verb "to be"',
      description: 'am, is, are',
      level: LanguageLevel.beginner,
      explanation:
          '"To be" is the most common verb in English. It describes who or '
          'what someone is. Its form changes with the pronoun.',
      rule: 'I → am\nhe / she / it → is\nyou / we / they → are',
      examples: [
        GrammarExample('I am tired.', 'Waan daallanahay.'),
        GrammarExample('He is a teacher.', 'Isagu waa macallin.'),
        GrammarExample('You are kind.', 'Adigu waad naxariis badan tahay.'),
        GrammarExample('We are friends.', 'Annagu waxaan nahay saaxiibbo.'),
      ],
      exercise: GrammarExercise(
        prompt: 'They ___ students.',
        options: ['am', 'is', 'are'],
        correctIndex: 2,
        explanation: '"They" always takes "are".',
      ),
    ),
    GrammarLesson(
      id: 'en_g3',
      languageCode: 'en',
      order: 3,
      title: 'Articles: a / an',
      description: 'When to use "a" and "an"',
      level: LanguageLevel.beginner,
      explanation:
          'Use "a" or "an" before one (singular) thing that is not specific. '
          'The choice depends on the first SOUND of the next word, not the '
          'letter.',
      rule:
          'a + consonant sound  →  a book, a car\nan + vowel sound  →  an apple, an hour',
      examples: [
        GrammarExample('I have a car.', 'Waxaan leeyahay baabuur.'),
        GrammarExample('She ate an apple.', 'Waxay cuntay tufaax.'),
        GrammarExample('It is an old house.', 'Waa guri duug ah.'),
      ],
      exercise: GrammarExercise(
        prompt: 'I want ___ egg for breakfast.',
        options: ['a', 'an', 'the'],
        correctIndex: 1,
        explanation: '"egg" starts with a vowel sound, so we use "an".',
      ),
    ),
    GrammarLesson(
      id: 'en_g4',
      languageCode: 'en',
      order: 4,
      title: 'Present simple',
      description: 'Habits and facts',
      level: LanguageLevel.intermediate,
      explanation:
          'Use the present simple for habits, routines and facts. With '
          'he, she and it, add -s (or -es) to the verb.',
      rule: 'I / you / we / they + verb\nhe / she / it + verb + s',
      examples: [
        GrammarExample(
          'I drink tea every morning.',
          'Subax kasta shaah ayaan cabbaa.',
        ),
        GrammarExample('She works in a bank.', 'Waxay ka shaqeysaa bangi.'),
        GrammarExample(
          'The sun rises in the east.',
          'Qorraxdu waxay ka soo baxdaa bari.',
        ),
      ],
      exercise: GrammarExercise(
        prompt: 'My brother ___ to school by bus.',
        options: ['go', 'goes', 'going'],
        correctIndex: 1,
        explanation: '"My brother" = he, so the verb takes -es: goes.',
      ),
    ),
    GrammarLesson(
      id: 'en_g5',
      languageCode: 'en',
      order: 5,
      title: 'Past simple',
      description: 'Finished actions in the past',
      level: LanguageLevel.intermediate,
      explanation:
          'Use the past simple for actions that started and finished in the '
          'past. Regular verbs add -ed. Many common verbs are irregular '
          '(go → went, eat → ate).',
      rule: 'verb + ed  →  visit → visited\nirregular  →  go → went',
      examples: [
        GrammarExample(
          'I visited my grandmother.',
          'Waxaan booqday ayeeyaday.',
        ),
        GrammarExample('We went to the beach.', 'Waxaan aadnay xeebta.'),
        GrammarExample('He ate rice yesterday.', 'Shalay wuxuu cunay bariis.'),
      ],
      exercise: GrammarExercise(
        prompt: 'Yesterday I ___ football with my friends.',
        options: ['play', 'played', 'playing'],
        correctIndex: 1,
        explanation: '"Yesterday" is the past, so we add -ed: played.',
      ),
    ),
    GrammarLesson(
      id: 'en_g6',
      languageCode: 'en',
      order: 6,
      title: 'Present perfect',
      description: 'Experiences and recent actions',
      level: LanguageLevel.advanced,
      explanation:
          'Use the present perfect for life experiences or past actions that '
          'matter now. We do not say exactly when they happened.',
      rule: 'have / has + past participle\nI have seen · she has eaten',
      examples: [
        GrammarExample('I have visited Turkey.', 'Waan booqday Turkiga.'),
        GrammarExample(
          'She has finished her work.',
          'Way dhammaysay shaqadeeda.',
        ),
        GrammarExample(
          'Have you ever eaten fish?',
          'Weligaa kalluun ma cuntay?',
        ),
      ],
      exercise: GrammarExercise(
        prompt: 'They ___ never been to Paris.',
        options: ['has', 'have', 'had'],
        correctIndex: 1,
        explanation: '"They" takes "have" in the present perfect.',
      ),
    ),

    // ---------------- Arabic ----------------
    GrammarLesson(
      id: 'ar_g1',
      languageCode: 'ar',
      order: 1,
      title: 'Personal pronouns',
      description: 'أنا، أنتَ، أنتِ، هو، هي',
      level: LanguageLevel.beginner,
      explanation:
          'Arabic pronouns change for male and female. "You" has two forms: '
          'أنتَ (anta) for a man and أنتِ (anti) for a woman.',
      rule: 'أنا = I · أنتَ / أنتِ = you\nهو = he · هي = she · نحن = we',
      examples: [
        GrammarExample('أنا طالب.', 'Anigu waxaan ahay arday.'),
        GrammarExample('هي معلمة.', 'Iyadu waa macallimad.'),
        GrammarExample('نحن أصدقاء.', 'Annagu waxaan nahay saaxiibbo.'),
      ],
      exercise: GrammarExercise(
        prompt: 'Which pronoun means "she"?',
        options: ['هو', 'هي', 'أنا'],
        correctIndex: 1,
        explanation: 'هي (hiya) means "she". هو (huwa) means "he".',
      ),
    ),
    GrammarLesson(
      id: 'ar_g2',
      languageCode: 'ar',
      order: 2,
      title: 'The definite article ال',
      description: 'Saying "the" in Arabic',
      level: LanguageLevel.beginner,
      explanation:
          'Arabic has no separate word for "the". Instead, add ال (al-) to '
          'the beginning of the noun.',
      rule: 'ال + noun\nكتاب (a book) → الكتاب (the book)',
      examples: [
        GrammarExample('بيت ← البيت', 'guri ← guriga'),
        GrammarExample('قلم ← القلم', 'qalin ← qalinka'),
        GrammarExample('الشمس حارة.', 'Qorraxdu way kulul tahay.'),
      ],
      exercise: GrammarExercise(
        prompt: 'How do you say "the house"?',
        options: ['بيت', 'البيت', 'بيوت'],
        correctIndex: 1,
        explanation: 'Add ال to بيت to make البيت (al-bayt).',
      ),
    ),
    GrammarLesson(
      id: 'ar_g3',
      languageCode: 'ar',
      order: 3,
      title: 'Masculine & feminine',
      description: 'The feminine ending ة',
      level: LanguageLevel.intermediate,
      explanation:
          'Most feminine nouns and adjectives end in ة (taa marbuuta). '
          'You can often make a word feminine by adding ة.',
      rule: 'masculine + ة = feminine\nطالب → طالبة',
      examples: [
        GrammarExample('معلم ← معلمة', 'macallin ← macallimad'),
        GrammarExample('طبيب ← طبيبة', 'dhakhtar ← dhakhtarad'),
        GrammarExample('هي طالبة ذكية.', 'Iyadu waa arday caqli badan.'),
      ],
      exercise: GrammarExercise(
        prompt: 'What is the feminine of معلم (teacher)?',
        options: ['معلمة', 'معلمون', 'المعلم'],
        correctIndex: 0,
        explanation: 'Add ة: معلم → معلمة.',
      ),
    ),

    // ---------------- Turkish ----------------
    GrammarLesson(
      id: 'tr_g1',
      languageCode: 'tr',
      order: 1,
      title: 'Plurals: -ler / -lar',
      description: 'Vowel harmony in plurals',
      level: LanguageLevel.beginner,
      explanation:
          'Turkish makes plurals with a suffix. Look at the LAST vowel of '
          'the word: e, i, ö, ü → -ler; a, ı, o, u → -lar.',
      rule:
          'e, i, ö, ü → -ler  (ev → evler)\na, ı, o, u → -lar  (kitap → kitaplar)',
      examples: [
        GrammarExample('ev → evler', 'guri → guryo'),
        GrammarExample('kitap → kitaplar', 'buug → buugaag'),
        GrammarExample('göz → gözler', 'il → indho'),
      ],
      exercise: GrammarExercise(
        prompt: 'What is the plural of "araba" (car)?',
        options: ['arabaler', 'arabalar', 'arabalır'],
        correctIndex: 1,
        explanation: 'The last vowel is "a", so we add -lar.',
      ),
    ),
    GrammarLesson(
      id: 'tr_g2',
      languageCode: 'tr',
      order: 2,
      title: '"To be" suffixes',
      description: 'I am, you are…',
      level: LanguageLevel.beginner,
      explanation:
          'Turkish has no separate verb "to be". Instead you add a personal '
          'suffix to the end of the word.',
      rule: 'I am → -(y)im\nyou are → -sin\nwe are → -(y)iz',
      examples: [
        GrammarExample('Öğrenciyim.', 'Waxaan ahay arday.'),
        GrammarExample('Doktorsun.', 'Waxaad tahay dhakhtar.'),
        GrammarExample('Mutluyuz.', 'Waan faraxsannahay.'),
      ],
      exercise: GrammarExercise(
        prompt: 'How do you say "I am a teacher"?',
        options: ['Öğretmenim', 'Öğretmensin', 'Öğretmen'],
        correctIndex: 0,
        explanation: 'Add -im for "I am": öğretmen + im.',
      ),
    ),
    GrammarLesson(
      id: 'tr_g3',
      languageCode: 'tr',
      order: 3,
      title: 'Present continuous -iyor',
      description: 'What is happening now',
      level: LanguageLevel.intermediate,
      explanation:
          'Use -iyor for actions happening now. Add it to the verb stem, '
          'then add the person ending.',
      rule: 'verb stem + iyor + person\ngel + iyor + um → geliyorum',
      examples: [
        GrammarExample('Geliyorum.', 'Waan imanayaa.'),
        GrammarExample('Çay içiyorsun.', 'Shaah ayaad cabbaysaa.'),
        GrammarExample('Kitap okuyoruz.', 'Buug ayaan akhrinaynaa.'),
      ],
      exercise: GrammarExercise(
        prompt: 'How do you say "I am coming"?',
        options: ['Geliyorum', 'Geliyorsun', 'Geldim'],
        correctIndex: 0,
        explanation: '-um is the ending for "I": geliyorum.',
      ),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Raw seeds. Each word has one Somali translation and per-language entries:
// (word, phonetic, example sentence).
// ---------------------------------------------------------------------------

typedef _Entry = (String, String, String);

class _WordSeed {
  const _WordSeed(
    this.key,
    this.emoji,
    this.somali,
    this.somaliExample,
    this.byLang,
  );

  final String key;
  final String emoji;
  final String somali;
  final String somaliExample;
  final Map<String, _Entry> byLang;
}

class _TopicSeed {
  const _TopicSeed(
    this.key,
    this.title,
    this.somaliTitle,
    this.color,
    this.words,
  );

  final String key;
  final String title;
  final String somaliTitle;
  final int color;
  final List<_WordSeed> words;
}

const _topicSeeds = <_TopicSeed>[
  _TopicSeed('family', 'Family', 'Qoyska', 0xFFEC4899, [
    _WordSeed('mother', '👩', 'Hooyo', 'Hooyaday waa macallimad.', {
      'en': ('Mother', '/ˈmʌð.ər/', 'My mother is a teacher.'),
      'ar': ('أم', 'umm', 'أمي معلمة.'),
      'tr': ('Anne', 'an-ne', 'Annem öğretmen.'),
    }),
    _WordSeed('father', '👨', 'Aabe', 'Aabahay wuxuu ka shaqeeyaa bangi.', {
      'en': ('Father', '/ˈfɑː.ðər/', 'My father works in a bank.'),
      'ar': ('أب', 'ab', 'أبي يعمل في بنك.'),
      'tr': ('Baba', 'ba-ba', 'Babam bankada çalışıyor.'),
    }),
    _WordSeed('brother', '👦', 'Walaal (wiil)', 'Walaalkay waa dheer yahay.', {
      'en': ('Brother', '/ˈbrʌð.ər/', 'My brother is tall.'),
      'ar': ('أخ', 'akh', 'أخي طويل.'),
      'tr': ('Erkek kardeş', 'er-kek kar-desh', 'Erkek kardeşim uzun.'),
    }),
    _WordSeed(
      'sister',
      '👧',
      'Walaasha',
      'Walaashay waxay jeceshahay muusigga.',
      {
        'en': ('Sister', '/ˈsɪs.tər/', 'My sister likes music.'),
        'ar': ('أخت', 'ukht', 'أختي تحب الموسيقى.'),
        'tr': ('Kız kardeş', 'kuz kar-desh', 'Kız kardeşim müziği sever.'),
      },
    ),
    _WordSeed('son', '🧒', 'Wiil', 'Wiilkoodu wuxuu aadaa dugsiga.', {
      'en': ('Son', '/sʌn/', 'Their son goes to school.'),
      'ar': ('ابن', 'ibn', 'ابنهم يذهب إلى المدرسة.'),
      'tr': ('Oğul', 'o-ul', 'Oğulları okula gidiyor.'),
    }),
    _WordSeed(
      'daughter',
      '👧🏽',
      'Gabadh',
      'Gabadhaydu aad bay u xariif tahay.',
      {
        'en': ('Daughter', '/ˈdɔː.tər/', 'My daughter is very smart.'),
        'ar': ('ابنة', 'ibna', 'ابنتي ذكية جداً.'),
        'tr': ('Kız', 'kuz', 'Kızım çok zeki.'),
      },
    ),
    _WordSeed(
      'grandfather',
      '👴',
      'Awoowe',
      'Awoowahay wuxuu sheegaa sheekooyin.',
      {
        'en': (
          'Grandfather',
          '/ˈɡræn.fɑː.ðər/',
          'My grandfather tells stories.',
        ),
        'ar': ('جد', 'jadd', 'جدي يحكي القصص.'),
        'tr': ('Dede', 'de-de', 'Dedem hikâyeler anlatır.'),
      },
    ),
    _WordSeed(
      'grandmother',
      '👵',
      'Ayeeyo',
      'Ayeeyaday si fiican ayay wax u karisaa.',
      {
        'en': ('Grandmother', '/ˈɡræn.mʌð.ər/', 'My grandmother cooks well.'),
        'ar': ('جدة', 'jadda', 'جدتي تطبخ جيداً.'),
        'tr': ('Büyükanne', 'bü-yük-an-ne', 'Büyükannem iyi yemek yapar.'),
      },
    ),
    _WordSeed('family', '👨‍👩‍👧', 'Qoys', 'Waan jeclahay qoyskayga.', {
      'en': ('Family', '/ˈfæm.əl.i/', 'I love my family.'),
      'ar': ('عائلة', 'ʿāʾila', 'أحب عائلتي.'),
      'tr': ('Aile', 'a-i-le', 'Ailemi seviyorum.'),
    }),
    _WordSeed('baby', '👶', 'Ilmo', 'Ilmuhu wuu hurdaa.', {
      'en': ('Baby', '/ˈbeɪ.bi/', 'The baby is sleeping.'),
      'ar': ('طفل', 'ṭifl', 'الطفل نائم.'),
      'tr': ('Bebek', 'be-bek', 'Bebek uyuyor.'),
    }),
  ]),
  _TopicSeed('food', 'Food', 'Cuntada', 0xFFF97316, [
    _WordSeed('water', '💧', 'Biyo', 'Ma i siin kartaa biyo?', {
      'en': ('Water', '/ˈwɔː.tər/', 'Can I have some water?'),
      'ar': ('ماء', 'māʾ', 'هل يمكنني الحصول على ماء؟'),
      'tr': ('Su', 'su', 'Biraz su alabilir miyim?'),
    }),
    _WordSeed('bread', '🍞', 'Rooti', 'Quraacda waxaan cunaa rooti.', {
      'en': ('Bread', '/bred/', 'I eat bread for breakfast.'),
      'ar': ('خبز', 'khubz', 'آكل الخبز في الفطور.'),
      'tr': ('Ekmek', 'ek-mek', 'Kahvaltıda ekmek yerim.'),
    }),
    _WordSeed('rice', '🍚', 'Bariis', 'Maalin kasta waxaan karinnaa bariis.', {
      'en': ('Rice', '/raɪs/', 'We cook rice every day.'),
      'ar': ('أرز', 'aruzz', 'نطبخ الأرز كل يوم.'),
      'tr': ('Pirinç', 'pi-rinch', 'Her gün pirinç pişiririz.'),
    }),
    _WordSeed('meat', '🥩', 'Hilib', 'Hilibkani aad buu u macaan yahay.', {
      'en': ('Meat', '/miːt/', 'This meat is delicious.'),
      'ar': ('لحم', 'laḥm', 'هذا اللحم لذيذ.'),
      'tr': ('Et', 'et', 'Bu et çok lezzetli.'),
    }),
    _WordSeed('milk', '🥛', 'Caano', 'Carruurtu waxay cabbaan caano.', {
      'en': ('Milk', '/mɪlk/', 'The children drink milk.'),
      'ar': ('حليب', 'ḥalīb', 'الأطفال يشربون الحليب.'),
      'tr': ('Süt', 'süt', 'Çocuklar süt içer.'),
    }),
    _WordSeed('apple', '🍎', 'Tufaax', 'Waxaan rabaa tufaax casaan ah.', {
      'en': ('Apple', '/ˈæp.əl/', 'I want a red apple.'),
      'ar': ('تفاحة', 'tuffāḥa', 'أريد تفاحة حمراء.'),
      'tr': ('Elma', 'el-ma', 'Kırmızı bir elma istiyorum.'),
    }),
    _WordSeed('banana', '🍌', 'Moos', 'Mooskani waa macaan yahay.', {
      'en': ('Banana', '/bəˈnɑː.nə/', 'This banana is sweet.'),
      'ar': ('موزة', 'mawza', 'هذه الموزة حلوة.'),
      'tr': ('Muz', 'muz', 'Bu muz tatlı.'),
    }),
    _WordSeed('tea', '🍵', 'Shaah', 'Ma rabtaa shaah?', {
      'en': ('Tea', '/tiː/', 'Would you like some tea?'),
      'ar': ('شاي', 'shāy', 'هل تريد بعض الشاي؟'),
      'tr': ('Çay', 'chai', 'Biraz çay ister misin?'),
    }),
    _WordSeed('egg', '🥚', 'Ukun', 'Waxaan karkariyay ukun.', {
      'en': ('Egg', '/eɡ/', 'I boiled an egg.'),
      'ar': ('بيضة', 'bayḍa', 'سلقت بيضة.'),
      'tr': ('Yumurta', 'yu-mur-ta', 'Bir yumurta haşladım.'),
    }),
    _WordSeed('fish', '🐟', 'Kalluun', 'Jimcaha waxaan cunnaa kalluun.', {
      'en': ('Fish', '/fɪʃ/', 'We eat fish on Friday.'),
      'ar': ('سمك', 'samak', 'نأكل السمك يوم الجمعة.'),
      'tr': ('Balık', 'ba-luk', 'Cuma günü balık yeriz.'),
    }),
  ]),
  _TopicSeed('travel', 'Travel', 'Safarka', 0xFF0EA5E9, [
    _WordSeed(
      'airport',
      '🛫',
      'Garoonka diyaaradaha',
      'Garoonka diyaaraduhu halkan wuu ka fog yahay.',
      {
        'en': ('Airport', '/ˈeə.pɔːt/', 'The airport is far from here.'),
        'ar': ('مطار', 'maṭār', 'المطار بعيد من هنا.'),
        'tr': ('Havalimanı', 'ha-va-li-ma-nu', 'Havalimanı buradan uzak.'),
      },
    ),
    _WordSeed(
      'ticket',
      '🎫',
      'Tigidh',
      'Waxaan u baahanahay tigidh Muqdisho ah.',
      {
        'en': ('Ticket', '/ˈtɪk.ɪt/', 'I need a ticket to Mogadishu.'),
        'ar': ('تذكرة', 'tadhkira', 'أحتاج تذكرة إلى مقديشو.'),
        'tr': ('Bilet', 'bi-let', "Mogadişu'ya bir bilet lazım."),
      },
    ),
    _WordSeed('passport', '🛂', 'Baasaboor', 'Fadlan tus baasaboorkaaga.', {
      'en': ('Passport', '/ˈpɑːs.pɔːt/', 'Please show your passport.'),
      'ar': ('جواز سفر', 'jawāz safar', 'من فضلك أظهر جواز سفرك.'),
      'tr': ('Pasaport', 'pa-sa-port', 'Lütfen pasaportunuzu gösterin.'),
    }),
    _WordSeed(
      'hotel',
      '🏨',
      'Hudheel',
      'Hudheelkayagu wuxuu u dhow yahay xeebta.',
      {
        'en': ('Hotel', '/həʊˈtel/', 'Our hotel is near the beach.'),
        'ar': ('فندق', 'funduq', 'فندقنا قريب من الشاطئ.'),
        'tr': ('Otel', 'o-tel', 'Otelimiz plaja yakın.'),
      },
    ),
    _WordSeed('car', '🚗', 'Baabuur', 'Waxaan kiraysannay baabuur.', {
      'en': ('Car', '/kɑːr/', 'We rented a car.'),
      'ar': ('سيارة', 'sayyāra', 'استأجرنا سيارة.'),
      'tr': ('Araba', 'a-ra-ba', 'Bir araba kiraladık.'),
    }),
    _WordSeed('train', '🚆', 'Tareen', 'Tareenku wuxuu baxayaa duhurka.', {
      'en': ('Train', '/treɪn/', 'The train leaves at noon.'),
      'ar': ('قطار', 'qiṭār', 'القطار يغادر عند الظهر.'),
      'tr': ('Tren', 'tren', 'Tren öğlen kalkıyor.'),
    }),
    _WordSeed('map', '🗺️', 'Khariidad', 'Aan eegno khariidadda.', {
      'en': ('Map', '/mæp/', "Let's look at the map."),
      'ar': ('خريطة', 'kharīṭa', 'لننظر إلى الخريطة.'),
      'tr': ('Harita', 'ha-ri-ta', 'Haritaya bakalım.'),
    }),
    _WordSeed('suitcase', '🧳', 'Shandad', 'Shandadaydu way culus tahay.', {
      'en': ('Suitcase', '/ˈsuːt.keɪs/', 'My suitcase is heavy.'),
      'ar': ('حقيبة', 'ḥaqība', 'حقيبتي ثقيلة.'),
      'tr': ('Bavul', 'ba-vul', 'Bavulum ağır.'),
    }),
    _WordSeed('beach', '🏖️', 'Xeeb', 'Xeebtu aad bay u qurux badan tahay.', {
      'en': ('Beach', '/biːtʃ/', 'The beach is beautiful.'),
      'ar': ('شاطئ', 'shāṭiʾ', 'الشاطئ جميل.'),
      'tr': ('Plaj', 'plazh', 'Plaj çok güzel.'),
    }),
    _WordSeed('road', '🛣️', 'Waddo', 'Waddadani waxay aadaysaa magaalada.', {
      'en': ('Road', '/rəʊd/', 'This road goes to the city.'),
      'ar': ('طريق', 'ṭarīq', 'هذا الطريق يذهب إلى المدينة.'),
      'tr': ('Yol', 'yol', 'Bu yol şehre gidiyor.'),
    }),
  ]),
  _TopicSeed('numbers', 'Numbers', 'Tirooyinka', 0xFF8B5CF6, [
    _WordSeed('one', '1️⃣', 'Kow (1)', 'Waxaan leeyahay hal bisad.', {
      'en': ('One', '/wʌn/', 'I have one cat.'),
      'ar': ('واحد', 'wāḥid', 'عندي قطة واحدة.'),
      'tr': ('Bir', 'bir', 'Bir kedim var.'),
    }),
    _WordSeed('two', '2️⃣', 'Laba (2)', 'Laba koob oo bun ah, fadlan.', {
      'en': ('Two', '/tuː/', 'Two coffees, please.'),
      'ar': ('اثنان', 'ithnān', 'قهوتان من فضلك.'),
      'tr': ('İki', 'i-ki', 'İki kahve lütfen.'),
    }),
    _WordSeed('three', '3️⃣', 'Saddex (3)', 'Dukaanku wuxuu furmaa saddexda.', {
      'en': ('Three', '/θriː/', 'The shop opens at three.'),
      'ar': ('ثلاثة', 'thalātha', 'يفتح المحل الساعة ثلاثة.'),
      'tr': ('Üç', 'üch', 'Dükkân saat üçte açılıyor.'),
    }),
    _WordSeed(
      'four',
      '4️⃣',
      'Afar (4)',
      'Baabuurku wuxuu leeyahay afar shaag.',
      {
        'en': ('Four', '/fɔːr/', 'A car has four wheels.'),
        'ar': ('أربعة', 'arbaʿa', 'للسيارة أربع عجلات.'),
        'tr': ('Dört', 'dört', 'Arabanın dört tekerleği var.'),
      },
    ),
    _WordSeed('five', '5️⃣', 'Shan (5)', 'Waxaan soo toosaa shanta.', {
      'en': ('Five', '/faɪv/', 'I wake up at five.'),
      'ar': ('خمسة', 'khamsa', 'أستيقظ الساعة خمسة.'),
      'tr': ('Beş', 'besh', 'Saat beşte uyanırım.'),
    }),
    _WordSeed('six', '6️⃣', 'Lix (6)', 'Waxaan haynaa lix kursi.', {
      'en': ('Six', '/sɪks/', 'We have six chairs.'),
      'ar': ('ستة', 'sitta', 'لدينا ستة كراسي.'),
      'tr': ('Altı', 'al-tu', 'Altı sandalyemiz var.'),
    }),
    _WordSeed(
      'seven',
      '7️⃣',
      'Toddoba (7)',
      'Toddobaadku wuxuu leeyahay toddoba maalmood.',
      {
        'en': ('Seven', '/ˈsev.ən/', 'A week has seven days.'),
        'ar': ('سبعة', 'sabʿa', 'في الأسبوع سبعة أيام.'),
        'tr': ('Yedi', 'ye-di', 'Bir haftada yedi gün var.'),
      },
    ),
    _WordSeed(
      'eight',
      '8️⃣',
      'Siddeed (8)',
      'Casharku wuxuu bilaabmaa siddeedda.',
      {
        'en': ('Eight', '/eɪt/', 'The class starts at eight.'),
        'ar': ('ثمانية', 'thamāniya', 'يبدأ الدرس الساعة ثمانية.'),
        'tr': ('Sekiz', 'se-kiz', 'Ders saat sekizde başlıyor.'),
      },
    ),
    _WordSeed('nine', '9️⃣', 'Sagaal (9)', 'Waxay jirtaa sagaal sano.', {
      'en': ('Nine', '/naɪn/', 'She is nine years old.'),
      'ar': ('تسعة', 'tisʿa', 'عمرها تسع سنوات.'),
      'tr': ('Dokuz', 'do-kuz', 'O dokuz yaşında.'),
    }),
    _WordSeed('ten', '🔟', 'Toban (10)', 'Waxaan haystaa toban buug.', {
      'en': ('Ten', '/ten/', 'I have ten books.'),
      'ar': ('عشرة', 'ʿashara', 'عندي عشرة كتب.'),
      'tr': ('On', 'on', 'On kitabım var.'),
    }),
  ]),
  _TopicSeed('colors', 'Colors', 'Midabada', 0xFF22C55E, [
    _WordSeed('red', '🔴', 'Casaan', 'Tufaaxu waa casaan.', {
      'en': ('Red', '/red/', 'The apple is red.'),
      'ar': ('أحمر', 'aḥmar', 'التفاحة لونها أحمر.'),
      'tr': ('Kırmızı', 'kur-mu-zu', 'Elma kırmızı.'),
    }),
    _WordSeed('blue', '🔵', 'Buluug', 'Cirku waa buluug.', {
      'en': ('Blue', '/bluː/', 'The sky is blue.'),
      'ar': ('أزرق', 'azraq', 'لون السماء أزرق.'),
      'tr': ('Mavi', 'ma-vi', 'Gökyüzü mavi.'),
    }),
    _WordSeed('green', '🟢', 'Cagaar', 'Cawsku waa cagaar.', {
      'en': ('Green', '/ɡriːn/', 'The grass is green.'),
      'ar': ('أخضر', 'akhḍar', 'العشب أخضر.'),
      'tr': ('Yeşil', 'ye-shil', 'Çimen yeşil.'),
    }),
    _WordSeed('yellow', '🟡', 'Jaalle', 'Mooskani waa jaalle.', {
      'en': ('Yellow', '/ˈjel.əʊ/', 'This banana is yellow.'),
      'ar': ('أصفر', 'aṣfar', 'لون هذه الموزة أصفر.'),
      'tr': ('Sarı', 'sa-ru', 'Bu muz sarı.'),
    }),
    _WordSeed('black', '⚫', 'Madow', 'Waxaan leeyahay bisad madow.', {
      'en': ('Black', '/blæk/', 'I have a black cat.'),
      'ar': ('أسود', 'aswad', 'عندي قط أسود.'),
      'tr': ('Siyah', 'si-yah', 'Siyah bir kedim var.'),
    }),
    _WordSeed('white', '⚪', 'Caddaan', 'Caanuhu waa caddaan.', {
      'en': ('White', '/waɪt/', 'Milk is white.'),
      'ar': ('أبيض', 'abyaḍ', 'الحليب أبيض.'),
      'tr': ('Beyaz', 'be-yaz', 'Süt beyaz.'),
    }),
    _WordSeed('orange', '🟠', 'Oranji', 'Shandadaydu waa oranji.', {
      'en': ('Orange', '/ˈɒr.ɪndʒ/', 'My bag is orange.'),
      'ar': ('برتقالي', 'burtuqālī', 'لون حقيبتي برتقالي.'),
      'tr': ('Turuncu', 'tu-run-ju', 'Çantam turuncu.'),
    }),
    _WordSeed('brown', '🟤', 'Bunni', 'Miisku waa bunni.', {
      'en': ('Brown', '/braʊn/', 'The table is brown.'),
      'ar': ('بني', 'bunnī', 'لون الطاولة بني.'),
      'tr': ('Kahverengi', 'kah-ve-ren-gi', 'Masa kahverengi.'),
    }),
    _WordSeed(
      'pink',
      '🩷',
      'Casaan khafiif',
      'Waxay xiran tahay dhar casaan khafiif ah.',
      {
        'en': ('Pink', '/pɪŋk/', 'She wears a pink dress.'),
        'ar': ('وردي', 'wardī', 'ترتدي فستاناً لونه وردي.'),
        'tr': ('Pembe', 'pem-be', 'Pembe bir elbise giyiyor.'),
      },
    ),
    _WordSeed('gray', '🩶', 'Cawl', 'Daruuruhu waa cawl.', {
      'en': ('Gray', '/ɡreɪ/', 'The clouds are gray.'),
      'ar': ('رمادي', 'ramādī', 'لون الغيوم رمادي.'),
      'tr': ('Gri', 'gri', 'Bulutlar gri.'),
    }),
  ]),
  _TopicSeed('greetings', 'Greetings', 'Salaamaha', 0xFFF59E0B, [
    _WordSeed('hello', '👋', 'Haye / Salaan', 'Haye, sidee tahay?', {
      'en': ('Hello', '/həˈləʊ/', 'Hello, how are you?'),
      'ar': ('مرحبا', 'marḥaban', 'مرحبا، كيف حالك؟'),
      'tr': ('Merhaba', 'mer-ha-ba', 'Merhaba, nasılsın?'),
    }),
    _WordSeed(
      'good_morning',
      '🌅',
      'Subax wanaagsan',
      'Subax wanaagsan, macallin!',
      {
        'en': ('Good morning', '/ɡʊd ˈmɔː.nɪŋ/', 'Good morning, teacher!'),
        'ar': ('صباح الخير', 'ṣabāḥ al-khayr', 'صباح الخير يا أستاذ!'),
        'tr': ('Günaydın', 'gü-nai-dun', 'Günaydın öğretmenim!'),
      },
    ),
    _WordSeed(
      'good_night',
      '🌙',
      'Habeen wanaagsan',
      'Habeen wanaagsan, si fiican u seexo.',
      {
        'en': ('Good night', '/ɡʊd naɪt/', 'Good night, sleep well.'),
        'ar': ('تصبح على خير', 'tuṣbiḥ ʿalā khayr', 'تصبح على خير يا صديقي.'),
        'tr': ('İyi geceler', 'i-yi ge-je-ler', 'İyi geceler, iyi uykular.'),
      },
    ),
    _WordSeed('thank_you', '🙏', 'Mahadsanid', 'Mahadsanid caawimaaddaada.', {
      'en': ('Thank you', '/θæŋk juː/', 'Thank you for your help.'),
      'ar': ('شكرا', 'shukran', 'شكرا على مساعدتك.'),
      'tr': (
        'Teşekkür ederim',
        'te-shek-kür e-de-rim',
        'Yardımın için teşekkür ederim.',
      ),
    }),
    _WordSeed('please', '🙂', 'Fadlan', 'Fadlan fadhiiso.', {
      'en': ('Please', '/pliːz/', 'Please sit down.'),
      'ar': ('من فضلك', 'min faḍlik', 'اجلس من فضلك.'),
      'tr': ('Lütfen', 'lüt-fen', 'Lütfen oturun.'),
    }),
    _WordSeed(
      'goodbye',
      '🫡',
      'Nabad gelyo',
      'Nabad gelyo, berri ayaan ku arki doonaa.',
      {
        'en': ('Goodbye', '/ɡʊdˈbaɪ/', 'Goodbye, see you tomorrow.'),
        'ar': ('مع السلامة', 'maʿa as-salāma', 'مع السلامة، أراك غداً.'),
        'tr': ('Hoşça kal', 'hosh-cha kal', 'Hoşça kal, yarın görüşürüz.'),
      },
    ),
    _WordSeed('how_are_you', '🤔', 'Sidee tahay?', 'Cali, sidee tahay?', {
      'en': ('How are you', '/haʊ ɑːr juː/', 'Hi Ali, how are you?'),
      'ar': ('كيف حالك', 'kayfa ḥāluk', 'أهلا علي، كيف حالك؟'),
      'tr': ('Nasılsın', 'na-sul-sun', 'Selam Ali, nasılsın?'),
    }),
    _WordSeed(
      'sorry',
      '😔',
      'Waan ka xumahay',
      'Waan ka xumahay, waan soo daahay.',
      {
        'en': ('Sorry', '/ˈsɒr.i/', 'Sorry, I am late.'),
        'ar': ('آسف', 'āsif', 'آسف، لقد تأخرت.'),
        'tr': ('Özür dilerim', 'ö-zür di-le-rim', 'Özür dilerim, geç kaldım.'),
      },
    ),
    _WordSeed('welcome', '🤗', 'Soo dhawoow', 'Ku soo dhawoow gurigayaga.', {
      'en': ('Welcome', '/ˈwel.kəm/', 'Welcome to our home.'),
      'ar': ('أهلا وسهلا', 'ahlan wa sahlan', 'أهلا وسهلا في بيتنا.'),
      'tr': ('Hoş geldiniz', 'hosh gel-di-niz', 'Evimize hoş geldiniz.'),
    }),
    _WordSeed('yes', '✅', 'Haa', 'Haa, waan fahmay.', {
      'en': ('Yes', '/jes/', 'Yes, I understand.'),
      'ar': ('نعم', 'naʿam', 'نعم، أفهم.'),
      'tr': ('Evet', 'e-vet', 'Evet, anlıyorum.'),
    }),
  ]),
];
