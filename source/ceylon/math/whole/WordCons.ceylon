class WordCons(word, tail) {
    shared variable Integer word;
    shared WordCons? tail;
}

WordCons? consOfWordsLowFirst(Words from) {
    variable WordCons? head = null;
    for (i in 0:from.size) {
        head = WordCons(get(from, i), head);
    }
    return head;
}

WordCons? consOfSize(Integer size) {
    variable WordCons? head = null;
    for (i in 0:size) {
        head = WordCons(0, head);
    }
    return head;
}

Words wordsOfConsLowFirst(variable WordCons? head, Integer length) {
    value result = newWords(length);
    variable value i = length-1;
    while (exists current = head, i >= 0) {
        set(result, i, current.word);
        head = current.tail;
        i--;
    }
    return result;
}
