# Gokabot for LINE.

## What

LINE BOT with Ruby, using [line-bot-sdk-ruby](https://github.com/line/line-bot-sdk-ruby).

## Usage

Add Gokabot to your friends from the QR code below, and invite to your groups.

![QR](./gokabotQR.png)

## Functions

- Calling

  | Send examples                 | Return          |
  |-------------------------------|-----------------|
  | "ごかぼっと", "gokabot""      | "なんですか？"  |
  | "ごかぼう", "ヒゲ", "gokabou" | Random response |

- Anime
  
  | Send examples                       | Return              |
  |-------------------------------------|---------------------|
  | "今日", "今日のアニメ", "today"     | Animes in today     |
  | "昨日", "昨日のアニメ", "yesterday" | Animes in yesterday |
  | "明日", "明日のアニメ", "tomorrow"  | Animes in tomorrow  |
  | "日曜", "日曜のアニメ", "Sunday"    | Animes in Sunday    |
  | "今期", "今期のアニメ", "all"       | Animes in this term |

- Weather

  | Send examples        | Return                         |
  |----------------------|--------------------------------|
  | "天気", "今日の天気" | Today's weather in Default     |
  | "明日の天気"         | Tomorrrow's weather in Default |
  | "天気 甲府"          | Today's weather in Kofu        |
  | "明日の天気 甲府"    | Tomorrow's weather in Kofu     |

  Now, Default is Tsukuba.
  
- Dictionary

  | Send examples                          | Return                                                       |
  |----------------------------------------|--------------------------------------------------------------|
  | "西郷隆盛ってなに", "西郷隆盛って誰？" | Informations of "西郷隆盛" in Wikipedia or pixiv or niconico |

- Nyokki

  | Send examples | Return            |
  |---------------|-------------------|
  | "1ニョッキ"   | Start Nyokki Game |

- Omikuji

  | Send examples | Return            |
  |---------------|-------------------|
  | "おみくじ"    | Result of Omikuji |

- Others

  See source code.

## How to add new function

1. Add file `hoge.rb` in `src/`.
2. Implement `answer(msg)` in class `Fuga` in `hoge.rb`.
3. Add `require 'hoge.rb'` to `app/imports.rb`.
4. Add `Fuga.new()` to `$OBJS` in `app/main.rb`.