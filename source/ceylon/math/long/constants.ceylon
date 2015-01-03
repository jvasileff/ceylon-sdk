shared Long zero = longNumber(0);
shared Long one = longNumber(1);
shared Long two = longNumber(2);
shared Long ten = longNumber(10);
Long negativeOne = longNumber(-1);

// These are used for Long.offset, so integerAddressableSize is irrelevant
Long integerMax = longNumber(runtime.maxIntegerValue);
Long integerMin = longNumber(runtime.minIntegerValue);

Integer minAddressableInteger = 1.leftLogicalShift(runtime.integerAddressableSize-1);
Integer maxAddressableInteger = minAddressableInteger.not;

Long longMin = longNumberOfWords(#8000, 0, 0, 0);
Long longMax = longNumberOfWords(#7fff, #ffff, #ffff, #ffff);

// FIXME
Boolean realInts = false && runtime.integerAddressableSize == 64;
