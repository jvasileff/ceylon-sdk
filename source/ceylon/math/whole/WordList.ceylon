class WordList(size = 0, highWord = null, lowWord = null) {
    shared variable Integer size;
    shared variable WordCell? highWord;
    shared variable WordCell? lowWord;

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

WordList wordListOfWords(Words from) {
    value fromSize = size(from);
    if (fromSize == 0) {
        return WordList();
    }
    WordCell highWord = WordCell(get(from, 0));
    variable WordCell higherWord = highWord;
    for (i in 1:fromSize-1) {
        value cell = WordCell(get(from, i));
        cell.nextHigher = higherWord;
        higherWord.nextLower = cell;
        higherWord = cell;
    }
    return WordList(fromSize, highWord, higherWord);
}

Words wordsOfWordList(WordList from) {
    value result = newWords(from.size);
    variable value iter = from.highWord;
    variable value i = 0;
    while (exists curr = iter) {
        set(result, i, curr.word);
        iter = curr.nextLower;
        i++;
    }
    return result;
}
