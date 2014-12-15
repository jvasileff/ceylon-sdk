class WordList(size = 0, highWord = null, lowWord = null) {
    shared variable Integer size;
    shared variable WordCell? highWord;
    shared variable WordCell? lowWord;

    shared WordCell unsafeHighWord {
        assert (exists result = highWord);
        return result;
    }

    shared WordCell unsafeLowWord {
        assert (exists result = lowWord);
        return result;
    }

    shared void normalize() {
        variable value newHigh = highWord;
        while (exists hw = newHigh, hw.word == 0) {
            size--;
            newHigh = hw.nextLower;
        }
        if (exists word = newHigh) {
            word.nextHigher = null;
        }
        highWord = newHigh;
    }

    shared void addHighWord(Integer word) {
        WordCell newHigh = WordCell(word, null, highWord);
        if (exists oldHigh = highWord) {
            oldHigh.nextHigher = newHigh;
        }
        highWord = newHigh;
        size++;
    }

    shared void removeHighWord() {
        assert (exists oldHigh = highWord);
        WordCell? newHigh = oldHigh.nextLower;
        if (exists newHigh) {
            newHigh.nextHigher = null;
        }
        else {
            lowWord = null;
        }
        highWord = newHigh;
        size--;
    }

    shared actual Boolean equals(Object that) {
        if (is WordList that) {
            if (size != that.size) {
                return false;
            }
            variable value thisIter = this.highWord;
            variable value thatIter = that.highWord;
            while (exists thisCurr = thisIter) {
                assert (exists thatCurr = thatIter);
                if (thisCurr.word != thatCurr.word) {
                    return false;
                }
                thisIter = thisCurr.nextLower;
                thatIter = thatCurr.nextLower;
            }
            return true;
        }
        else {
            return false;
        }
    }
}

WordList wordListOfOne(Integer word) {
    WordCell cell = WordCell(word);
    return WordList(1, cell, cell);
}

WordList wordListOfSize(Integer size) {
    if (size == 0) {
        return WordList();
    }
    WordCell highWord = WordCell(0);
    variable WordCell higherWord = highWord;
    for (i in 1:size-1) {
        value cell = WordCell(0, higherWord);
        higherWord.nextLower = cell;
        higherWord = cell;
    }
    return WordList(size, highWord, higherWord);
}

WordList wordListCopy(WordList source) { // TODO untested
    if (source.size == 0) {
        return WordList();
    }
    assert (exists sourceHigh = source.highWord);
    WordCell highWord = WordCell(sourceHigh.word);
    variable WordCell higherWord = highWord;
    variable value sourceIter = sourceHigh.nextLower;
    while (exists sourceCurr = sourceIter) {
        value cell = WordCell(sourceCurr.word, higherWord);
        higherWord.nextLower = cell;
        higherWord = cell;
        sourceIter = sourceCurr.nextLower;
    }
    return WordList(source.size, highWord, higherWord);
}
