package gokabou

import (
	"context"
	"database/sql"
	"log/slog"
	"math/rand/v2"
	"os"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/23prime/gokabot-api/internal/answerer"
	"github.com/ikawaha/kagome-dict/ipa"
	"github.com/ikawaha/kagome/v2/tokenizer"
)

const (
	version             = "2.0.0"
	upperBoundBlockConn = 9
	minMsgRunes         = 4 // Ruby: msg.length > 4 means len > 4, so reject <= 4
	maxMsgRunes         = 300

	// sentinel marks sentence boundaries in the Markov chain (nil in Ruby).
	sentinel = "\x00"

	help = "-- [-h][--help]：ヘルプを呼びます．\n" +
		"-- [-v][--version]：バージョン等を確認します．\n\n" +
		"-- ごかぼっと：呼び出せます．\n" +
		"-- ごかぼう：何か返します．\n\n" +
		"-- 死ね：死んだり死ななかったりします．\n\n" +
		"-- ぬるぽ：ｶﾞｯ\n\n" +
		"-- おみくじ：おみくじを引けます（結果は日替わり）．\n\n" +
		"-- 今日のアニメ：その日に放送するアニメを返します．\n" +
		"-- 昨日のアニメ：前日に放送したアニメを返します．\n" +
		"-- 明日アニメ：翌日に放送するアニメを返します．\n" +
		"-- 今期のアニメ：その期日に放送するアニメを返します．\n\n" +
		"-- ↓曜日の指定もできます．\n" +
		"-- 日曜日：日曜日に放送するアニメを返します．"
)

var omikuji = []string{
	"ハズレで〜すｗ",
	"［大吉］「黄金のヒゲ」が生えてきます！やったね！",
	"［吉］いつもより綺麗にヒゲが剃れるでしょう",
	"［吉］今ならヒゲ剃りの替刃がセールで安い！",
	"［吉］トリートメントでヒゲがサラサラに！",
	"［中吉］新たなヒゲとの出会いがあるかも！",
	"［中吉］ヒゲの話で盛り上がります",
	"［小吉］よくヒゲが抜けます",
	"［小吉］ヒゲがステキな男性との出会いがあるかも",
	"［末吉］ヒゲが濃い一日になるでしょう",
	"［末吉］ヒゲが伸びてると女子高生に笑われます",
	"［凶］ヒゲ剃りで出血します",
	"［凶］ヒゲ剃りが壊れます",
	"［凶］ヒゲがモミアゲと繋がります",
	"［凶］ヒゲが排水溝に詰まります",
	"［大凶］ごかぼうになるでしょう",
}

var deads = []string{
	"いや、死なないよ。",
	"死ぬ〜〜〜〜〜ｗ",
	"死んだｗ",
	"おいおい…",
	"死んダダダダダダーン",
	"人に死ねなんて言葉使うな😡",
	"死ぬまで死なないよ",
	"死ねのバーゲンセールかよ",
	"きみ、死ねしか言えないの？",
	"そっちからリプ送ってきて死ねっつうな！死ね！しねしねこうせん！💨",
	"いやでｗｗｗいやでござるｗｗｗ",
	"し、しにたくないでおぢゃる〜ｗｗｗ",
}

var newYears = []string{
	"あけおめでつｗ",
	"Happy New Year でござるｗｗ",
	"は？",
	"ことよろチクビｗ",
	"今年はヒゲを剃りたい",
}

var (
	konRe      = regexp.MustCompile(`(?i)^こん(|です)(|ｗ|w)$`)
	deathRe    = regexp.MustCompile(`死ね|死んで`)
	ikuRe      = regexp.MustCompile(`行く`)
	versionRe  = regexp.MustCompile(`^gokabot\s+(-v|--version)$`)
	helpRe     = regexp.MustCompile(`^gokabot\s+(-h|--help)$`)
	omikujiRe  = regexp.MustCompile(`^おみくじ$`)
	takenokoRe = regexp.MustCompile(`たけのこ(君|くん|さん|ちゃん|)`)
	nurupoRe   = regexp.MustCompile(`^ぬるぽ$`)
	newYearRe  = regexp.MustCompile(`(?i)あけ|明け|おめ|こん|おは|happy|new|year|2019`)
	markovRe   = regexp.MustCompile(`ごかぼっと|gokabot|ごかぼう|gokabou|^ヒゲ$|^ひげ$`)
	uriRe      = regexp.MustCompile(`https?://\S+`)
)

// markovBlock is a 3-gram [prev, curr, next] using sentinel for boundaries.
type markovBlock [3]string

// Answerer responds to various triggers and generates Markov chain text from
// sentences stored in the gokabot.gokabous DB table.
type Answerer struct {
	db         *sql.DB
	tok        *tokenizer.Tokenizer
	gokabouUID string
	mu         sync.RWMutex
	markovDict []markovBlock
}

func New(db *sql.DB) *Answerer {
	tok, err := tokenizer.New(ipa.Dict(), tokenizer.OmitBosEos())
	if err != nil {
		slog.Error("gokabou: failed to initialize kagome tokenizer", "error", err)
	}

	a := &Answerer{
		db:         db,
		tok:        tok,
		gokabouUID: os.Getenv("GOKABOU_USER_ID"),
	}
	a.rebuildDict(context.Background())
	return a
}

func (a *Answerer) Answer(data answerer.MessageData) *answerer.Response {
	msg := data.Message
	uid := data.UserID

	// Always attempt to learn from the message (matches Ruby's update_dict on every call).
	a.updateDict(context.Background(), msg, uid)

	switch {
	case konRe.MatchString(msg):
		return text("こん")
	case deathRe.MatchString(msg):
		return text(deads[rand.IntN(len(deads))]) //nolint:gosec
	case ikuRe.MatchString(msg):
		return text("俺もイク！ｗ")
	case versionRe.MatchString(msg):
		return text(version)
	case helpRe.MatchString(msg):
		return text(help)
	case omikujiRe.MatchString(msg):
		return text(omikuji[rand.IntN(len(omikuji))]) //nolint:gosec
	case takenokoRe.MatchString(msg):
		return text("たけのこ君ｐｒｐｒ")
	case nurupoRe.MatchString(msg):
		return text("ｶﾞｯ")
	case newYearRe.MatchString(msg) && isNewYear():
		return text(newYears[rand.IntN(len(newYears))]) //nolint:gosec
	case markovRe.MatchString(msg):
		return text(a.genText())
	}
	return nil
}

func text(s string) *answerer.Response {
	return &answerer.Response{Text: s, ReplyType: "text"}
}

func isNewYear() bool {
	now := time.Now()
	return now.Month() == time.January && now.Day() == 1
}

// updateDict saves msg to the DB and rebuilds the Markov dictionary if the
// message qualifies (right user, length 5–300, no URI, not a duplicate).
func (a *Answerer) updateDict(ctx context.Context, msg, userID string) {
	if !a.updatable(ctx, msg, userID) {
		return
	}
	_, err := a.db.ExecContext(ctx,
		`INSERT INTO gokabot.gokabous (reg_date, sentence) VALUES ($1, $2)`,
		time.Now().Format("2006-01-02"), msg,
	)
	if err != nil {
		slog.Warn("gokabou: failed to insert sentence", "error", err)
		return
	}
	slog.Info("gokabou: dictionary updated")
	a.rebuildDict(ctx)
}

func (a *Answerer) updatable(ctx context.Context, msg, userID string) bool {
	if a.gokabouUID == "" || userID != a.gokabouUID {
		return false
	}
	n := len([]rune(msg))
	if n <= minMsgRunes || n > maxMsgRunes {
		return false
	}
	if uriRe.MatchString(msg) {
		return false
	}
	var count int
	if err := a.db.QueryRowContext(ctx,
		`SELECT COUNT(*) FROM gokabot.gokabous WHERE sentence = $1`, msg,
	).Scan(&count); err != nil {
		slog.Warn("gokabou: failed to check duplicate", "error", err)
		return false
	}
	return count == 0
}

func (a *Answerer) rebuildDict(ctx context.Context) {
	rows, err := a.db.QueryContext(ctx, `SELECT sentence FROM gokabot.gokabous`)
	if err != nil {
		slog.Warn("gokabou: failed to load sentences", "error", err)
		return
	}
	defer rows.Close() //nolint:errcheck

	var dict []markovBlock
	var sentenceCount, wordCount int
	for rows.Next() {
		var sentence string
		if err := rows.Scan(&sentence); err != nil {
			continue
		}
		words := a.tokenize(sentence)
		sentenceCount++
		wordCount += len(words)
		dict = append(dict, buildBlocks(words)...)
	}
	slog.Info("gokabou: dict built", "sentences", sentenceCount, "words", wordCount)

	a.mu.Lock()
	a.markovDict = dict
	a.mu.Unlock()
}

func (a *Answerer) tokenize(sentence string) []string {
	if a.tok == nil {
		return strings.Fields(sentence)
	}
	tokens := a.tok.Tokenize(sentence)
	words := make([]string, 0, len(tokens))
	for _, t := range tokens {
		if s := t.Surface; s != "" {
			words = append(words, s)
		}
	}
	return words
}

// buildBlocks converts a word slice into overlapping 3-grams with sentinel boundaries.
// Mirrors Ruby's gen_markov_block: prepend/append nil, then slide a window of 3.
//
// For words [w1, w2, w3]:
//
//	[sentinel, w1, w2]
//	[w1, w2, w3]
//	[w2, w3, sentinel]
func buildBlocks(words []string) []markovBlock {
	n := len(words)
	if n == 0 {
		return nil
	}
	blocks := make([]markovBlock, n)
	for i := range n {
		if i == 0 {
			blocks[i][0] = sentinel
		} else {
			blocks[i][0] = words[i-1] //nolint:gosec
		}
		blocks[i][1] = words[i] //nolint:gosec
		if i+1 < n {
			blocks[i][2] = words[i+1] //nolint:gosec
		} else {
			blocks[i][2] = sentinel
		}
	}
	return blocks
}

func (a *Answerer) genText() string {
	a.mu.RLock()
	dict := make([]markovBlock, len(a.markovDict))
	copy(dict, a.markovDict)
	a.mu.RUnlock()

	if len(dict) == 0 {
		return "…"
	}
	return genMarkovText(dict)
}

// genMarkovText generates a sentence by traversing the Markov chain.
// Mirrors Ruby's gen_text: pick a random start block, then extend by finding
// blocks whose prev matches the last accumulated word.
func genMarkovText(dict []markovBlock) string {
	var starts []markovBlock
	for _, b := range dict {
		if b[0] == sentinel {
			starts = append(starts, b)
		}
	}
	if len(starts) == 0 {
		return "…"
	}

	// result grows as we extend; Ruby does result.concat(block[1..])
	start := starts[rand.IntN(len(starts))] //nolint:gosec
	result := []string{start[1], start[2]}

	for range upperBoundBlockConn {
		last := result[len(result)-1]
		if last == sentinel {
			break
		}
		var candidates []markovBlock
		for _, b := range dict {
			if b[0] == last {
				candidates = append(candidates, b)
			}
		}
		if len(candidates) == 0 {
			break
		}
		next := candidates[rand.IntN(len(candidates))] //nolint:gosec
		result = append(result, next[1], next[2])      // block[1..]
	}

	var sb strings.Builder
	for _, w := range result {
		if w != sentinel {
			sb.WriteString(w)
		}
	}
	return sb.String()
}
