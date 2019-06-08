# Gokabot for LINE

## What

LINE BOT with Ruby, using [line-bot-sdk-ruby](https://github.com/line/line-bot-sdk-ruby).

## Usage

Add Gokabot to your friends from the QR code below, and invite to your groups.

![QR](./images/gokabotQR.png)

## Functions

- Calling

  | Send examples                    | Response        |
  |----------------------------------|-----------------|
  | "ごかぼっと", "ごかぼう", "ヒゲ" | Random message  |

- Anime
  
  | Send examples                       | Response                        |
  |-------------------------------------|---------------------------------|
  | "今日", "今日のアニメ", "today"     | Animes in today                 |
  | "昨日", "昨日のアニメ", "yesterday" | Animes in yesterday             |
  | "明日", "明日のアニメ", "tomorrow"  | Animes in tomorrow              |
  | "日曜", "日曜のアニメ", "Sunday"    | Animes in Sunday                |
  | "今期", "今期のアニメ", "all"       | Animes in this term             |
  | "来期", "来期のアニメ", "next"      | Animes in next term             |
  | "おすすめ"                          | Recommended animes in today     |
  | "今期のおすすめ"                    | Recommended animes in this term |

- Weather

  | Send examples        | Response                       |
  |----------------------|--------------------------------|
  | "天気", "今日の天気" | Today's weather in Default     |
  | "明日の天気"         | Tomorrrow's weather in Default |
  | "天気 東京"          | Today's weather in Tokyo       |
  | "明日の天気 東京"    | Tomorrow's weather in Tokyo    |

  Now, Default is Tsukuba.
  
- Dictionary

  | Send examples                          | Response                                                     |
  |----------------------------------------|--------------------------------------------------------------|
  | "西郷隆盛ってなに", "西郷隆盛って誰？" | Informations of "西郷隆盛" in Wikipedia or pixiv or niconico |

- Nyokki

  | Send examples | Response          |
  |---------------|-------------------|
  | "1ニョッキ"   | Start Nyokki Game |

- Omikuji

  | Send examples | Response          |
  |---------------|-------------------|
  | "おみくじ"    | Result of Omikuji |

- Others

  See source code.

## How to add new function

1. Create new file `/app/src/hoge.rb`.
2. Implement class `Fuga` in `hoge.rb`.
3. Implement instance method `answer(msg)` in class `Fuga`.
4. Add `require_relative './src/hoge.rb'` to `/app/src.rb`.
5. Add `Fuga.new` to `$OBJS` in `src.rb`.

### Coding rules

We define our coding rules in `.rubocop.yml`.  
So, please install [RuboCop](https://rubocop.readthedocs.io/), and check your code by it.
