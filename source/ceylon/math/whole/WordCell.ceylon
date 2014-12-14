class WordCell(word = 0, nextHigher = null, nextLower = null) {
    shared variable Integer word;
    shared variable WordCell? nextHigher;
    shared variable WordCell? nextLower;

    shared WordCell unsafeHigher {
        assert (exists ret = nextHigher);
        return ret;
    }

    shared WordCell unsafeLower {
        assert (exists ret = nextLower);
        return ret;
    }

}
