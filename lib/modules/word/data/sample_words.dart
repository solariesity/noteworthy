import '../models/word_entry.dart';

const List<WordEntry> sampleWords = [
  WordEntry(
    word: 'ephemeral',
    pronunciation: '/ɪˈfem.ər.əl/',
    definitionCn: '短暂的，转瞬即逝的',
    definitionEn: 'lasting for a very short time',
    partOfSpeech: 'adj.',
    difficulty: 'B2',
    examples: [
      ExampleSentence(en: 'Fame is ephemeral.', cn: '名声是短暂的。'),
      ExampleSentence(
        en: 'The ephemeral beauty of cherry blossoms draws crowds every spring.',
        cn: '樱花转瞬即逝的美每年春天都吸引着人群。',
      ),
    ],
    rootAnalysis: RootAnalysis(
      overallMeaning: 'lasting only for a day',
      components: [
        RootComponent(part: 'epi-', meaning: 'upon, on', origin: 'Greek'),
        RootComponent(part: 'hemera', meaning: 'day', origin: 'Greek'),
        RootComponent(part: '-al', meaning: 'adjective suffix', origin: 'Latin'),
      ],
    ),
    collocations: [
      Collocation(phrase: 'ephemeral beauty', meaning: '转瞬即逝的美'),
      Collocation(phrase: 'ephemeral nature', meaning: '短暂的本质'),
    ],
  ),
  WordEntry(
    word: 'ubiquitous',
    pronunciation: '/juːˈbɪk.wɪ.təs/',
    definitionCn: '无处不在的',
    definitionEn: 'present, appearing, or found everywhere',
    partOfSpeech: 'adj.',
    difficulty: 'C1',
    examples: [
      ExampleSentence(
        en: 'Smartphones have become ubiquitous in modern life.',
        cn: '智能手机在现代生活中已无处不在。',
      ),
    ],
    collocations: [
      Collocation(phrase: 'ubiquitous presence', meaning: '无处不在的存在'),
      Collocation(phrase: 'ubiquitous computing', meaning: '普适计算'),
    ],
  ),
  WordEntry(
    word: 'serendipity',
    pronunciation: '/ˌser.ənˈdɪp.ə.ti/',
    definitionCn: '意外发现珍奇事物的本领，机缘巧合',
    definitionEn: 'the occurrence of events by chance in a happy way',
    partOfSpeech: 'n.',
    difficulty: 'C2',
    examples: [
      ExampleSentence(
        en: 'Finding that book was pure serendipity.',
        cn: '找到那本书纯属机缘巧合。',
      ),
    ],
    collocations: [
      Collocation(phrase: 'pure serendipity', meaning: '纯粹的机缘'),
      Collocation(phrase: 'a moment of serendipity', meaning: '灵光乍现的时刻'),
    ],
  ),
  WordEntry(
    word: 'eloquent',
    pronunciation: '/ˈel.ə.kwənt/',
    definitionCn: '雄辩的，有口才的',
    definitionEn: 'fluent or persuasive in speaking or writing',
    partOfSpeech: 'adj.',
    difficulty: 'B2',
    examples: [
      ExampleSentence(
        en: 'She gave an eloquent speech about the importance of education.',
        cn: '她就教育的重要性发表了一番雄辩的演讲。',
      ),
    ],
    collocations: [
      Collocation(phrase: 'eloquent testimony', meaning: '有力的证词'),
      Collocation(phrase: 'eloquent silence', meaning: '意味深长的沉默'),
    ],
  ),
  WordEntry(
    word: 'nostalgia',
    pronunciation: '/nɒˈstæl.dʒə/',
    definitionCn: '怀旧，乡愁',
    definitionEn: 'a sentimental longing for the past',
    partOfSpeech: 'n.',
    difficulty: 'B2',
    examples: [
      ExampleSentence(
        en: 'The old song filled her with nostalgia.',
        cn: '那首老歌让她充满了怀旧之情。',
      ),
    ],
    collocations: [
      Collocation(phrase: 'wave of nostalgia', meaning: '一阵怀旧之情'),
      Collocation(phrase: 'nostalgia for childhood', meaning: '对童年的怀念'),
    ],
  ),
  WordEntry(
    word: 'resilient',
    pronunciation: '/rɪˈzɪl.i.ənt/',
    definitionCn: '有韧性的，能迅速恢复的',
    definitionEn: 'able to withstand or recover quickly from difficult conditions',
    partOfSpeech: 'adj.',
    difficulty: 'C1',
    examples: [
      ExampleSentence(
        en: 'Children are often more resilient than adults think.',
        cn: '孩子们往往比成年人想象的更有韧性。',
      ),
    ],
    rootAnalysis: RootAnalysis(
      overallMeaning: 'springing back',
      components: [
        RootComponent(part: 're-', meaning: 'back, again', origin: 'Latin'),
        RootComponent(part: 'salire', meaning: 'to jump, leap', origin: 'Latin'),
        RootComponent(part: '-ent', meaning: 'adjective suffix', origin: 'Latin'),
      ],
    ),
    collocations: [
      Collocation(phrase: 'resilient economy', meaning: '韧性经济'),
      Collocation(phrase: 'highly resilient', meaning: '高度弹性的'),
    ],
  ),
  WordEntry(
    word: 'ambiguous',
    pronunciation: '/æmˈbɪɡ.ju.əs/',
    definitionCn: '模棱两可的，含糊的',
    definitionEn: 'open to more than one interpretation',
    partOfSpeech: 'adj.',
    difficulty: 'B2',
    examples: [
      ExampleSentence(
        en: 'The wording of the contract is deliberately ambiguous.',
        cn: '合同的措辞故意模棱两可。',
      ),
    ],
    collocations: [
      Collocation(phrase: 'deliberately ambiguous', meaning: '故意含糊其辞'),
      Collocation(phrase: 'ambiguous statement', meaning: '模棱两可的陈述'),
    ],
  ),
  WordEntry(
    word: 'pragmatic',
    pronunciation: '/præɡˈmæt.ɪk/',
    definitionCn: '务实的，实用的',
    definitionEn: 'dealing with things sensibly and realistically',
    partOfSpeech: 'adj.',
    difficulty: 'C1',
    examples: [
      ExampleSentence(
        en: 'We need a pragmatic approach to this problem.',
        cn: '我们需要一个务实的方法来解决这个问题。',
      ),
    ],
    collocations: [
      Collocation(phrase: 'pragmatic approach', meaning: '务实的方法'),
      Collocation(phrase: 'pragmatic solution', meaning: '实用的解决方案'),
    ],
  ),
  WordEntry(
    word: 'altruistic',
    pronunciation: '/ˌæl.truˈɪs.tɪk/',
    definitionCn: '利他的，无私的',
    definitionEn: 'showing a selfless concern for the well-being of others',
    partOfSpeech: 'adj.',
    difficulty: 'C1',
    examples: [
      ExampleSentence(
        en: 'Her altruistic actions inspired the entire community.',
        cn: '她的无私行为激励了整个社区。',
      ),
    ],
    collocations: [
      Collocation(phrase: 'altruistic behavior', meaning: '利他行为'),
      Collocation(phrase: 'purely altruistic', meaning: '纯粹利他的'),
    ],
  ),
];
