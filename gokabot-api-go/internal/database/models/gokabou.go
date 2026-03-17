package models

import "time"

type Gokabou struct {
	ID       int
	RegDate  time.Time
	Sentence string
}
