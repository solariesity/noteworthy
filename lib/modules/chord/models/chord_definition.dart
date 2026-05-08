class ChordDefinition {
  final String id;
  final String nameCn;
  final String nameEn;
  final List<int> intervals;
  final String quality;
  final String color;

  const ChordDefinition({
    required this.id,
    required this.nameCn,
    required this.nameEn,
    required this.intervals,
    required this.quality,
    required this.color,
  });

  static const List<ChordDefinition> all = [
    ChordDefinition(
      id: 'maj', nameCn: '大三和弦', nameEn: 'Major',
      intervals: [0, 4, 7], quality: 'major', color: '明亮',
    ),
    ChordDefinition(
      id: 'min', nameCn: '小三和弦', nameEn: 'Minor',
      intervals: [0, 3, 7], quality: 'minor', color: '阴暗',
    ),
    ChordDefinition(
      id: 'dim', nameCn: '减三和弦', nameEn: 'Diminished',
      intervals: [0, 3, 6], quality: 'diminished', color: '紧张',
    ),
    ChordDefinition(
      id: 'aug', nameCn: '增三和弦', nameEn: 'Augmented',
      intervals: [0, 4, 8], quality: 'augmented', color: '漂浮',
    ),
    ChordDefinition(
      id: 'sus2', nameCn: '挂二和弦', nameEn: 'Sus2',
      intervals: [0, 2, 7], quality: 'suspended', color: '空灵',
    ),
    ChordDefinition(
      id: 'sus4', nameCn: '挂四和弦', nameEn: 'Sus4',
      intervals: [0, 5, 7], quality: 'suspended', color: '悬停',
    ),
    ChordDefinition(
      id: 'dom7', nameCn: '属七和弦', nameEn: 'Dominant 7',
      intervals: [0, 4, 7, 10], quality: 'dominant', color: '推动',
    ),
    ChordDefinition(
      id: 'maj7', nameCn: '大七和弦', nameEn: 'Major 7',
      intervals: [0, 4, 7, 11], quality: 'major', color: '梦幻',
    ),
    ChordDefinition(
      id: 'min7', nameCn: '小七和弦', nameEn: 'Minor 7',
      intervals: [0, 3, 7, 10], quality: 'minor', color: '忧郁',
    ),
    ChordDefinition(
      id: 'dim7', nameCn: '减七和弦', nameEn: 'Diminished 7',
      intervals: [0, 3, 6, 9], quality: 'diminished', color: '暗沉',
    ),
    ChordDefinition(
      id: 'hdim7', nameCn: '半减七', nameEn: 'Half-Dim 7',
      intervals: [0, 3, 6, 10], quality: 'diminished', color: '灰蒙',
    ),
    ChordDefinition(
      id: 'aug7', nameCn: '增大七', nameEn: 'Augmented 7',
      intervals: [0, 4, 8, 11], quality: 'augmented', color: '锋利',
    ),
  ];
}
