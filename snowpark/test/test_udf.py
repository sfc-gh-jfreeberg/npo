# Simple test for count_words UDF
from src.utils.udfs import count_words

def test_count_words_basic():
	sql = "SELECT * FROM users WHERE age > 21"
	assert count_words(sql) == 8

def test_count_words_empty():
	assert count_words("") == 0

def test_count_words_none():
	assert count_words(None) == 0
