const kAppVersion = 'v0.6.0';

// MIDI note numbers for octave roots (C2..C6).
// MIDI 标准：C-1 = 0，每升八度 +12，C4 (中央 C) = 60。
const kMidiC2 = 36;
const kMidiC3 = 48;
const kMidiC4 = 60;
const kMidiC5 = 72;
const kMidiC6 = 84;

// 钢琴展示与练习中使用的音域上下限。
const kPianoMinNote = kMidiC2; // 36
const kPianoMaxNote = kMidiC6; // 84

// MIDI 协议合法的最大音符号。
const kMidiMaxNote = 127;

// 12 个音名（半音阶），从 C 开始。
const kNoteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
