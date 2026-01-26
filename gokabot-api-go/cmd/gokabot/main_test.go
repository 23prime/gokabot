package main

import "testing"

func TestMain(t *testing.T) {
	expected := "Hello"
	result := "Hello"

	if result != expected {
		t.Errorf("Expected %q but got %q", expected, result)
	}
}
