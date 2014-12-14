"An arbitrary precision integer."
shared final class Whole
        satisfies Integral<Whole> &
                  Exponentiable<Whole, Whole> {

    shared actual Integer sign;

    WordList words;

    variable Integer? integerMemo = null;

    variable String? stringMemo = null;

    shared new Internal(Integer sign, variable WordList words) {
        // FIXME should be package private when available
        words.normalize();

        // words must fit with word-size bits
        //if (words.any((word) => word != word.and(wordMask))) {
        //    throw OverflowException("Invalid word");
        //}

        // sign must not be 0 if magnitude != 0
        assert (-1 <= sign <= 1);
        assert (!sign == 0 || words.size == 0);

        this.sign = if (words.size == 0) then 0 else sign;
        this.words = words;
    }

    shared actual Whole plus(Whole other)
        =>  if (zero) then
                other
            else if (other.zero) then
                this
            else if (sign == other.sign) then
                Internal(sign, add(words, other.words))
            else
               (switch (compareMagnitude(this.words, other.words))
                case (equal)
                    package.zero
                case (larger)
                    Internal(sign, subtract(words, other.words))
                case (smaller)
                    Internal(sign.negated, subtract(other.words, words)));

    shared actual Whole plusInteger(Integer integer)
        =>  plus(wholeNumber(integer));

    shared actual Whole times(Whole other)
        =>  if (this.zero || other.zero) then
                package.zero
            else if (this.unit) then
                other
            else if (this == negativeOne) then
                other.negated
            else
                Internal(this.sign * other.sign, multiply(words, other.words));

    shared actual Whole timesInteger(Integer integer)
        =>  times(wholeNumber(integer));

    // TODO doc
    shared [Whole, Whole] quotientAndRemainder(Whole other) {
        if (other.zero) {
            throw Exception("Divide by zero");
        }
        return if (zero) then
            [package.zero, package.zero]
        else if (other.unit) then
            [this, package.zero]
        else if (other == package.negativeOne) then
            [this.negated, package.zero]
        else (
            switch (compareMagnitude(this.words, other.words))
            case (equal)
                [if (sign == other.sign)
                    then package.one
                    else package.negativeOne,
                 package.zero]
            case (smaller)
                [package.zero, this]
            case (larger)
                (let (resultWords   = divide(this.words, other.words))
                 [Internal(sign * other.sign, resultWords.first),
                  Internal(sign, resultWords.last)]));
    }

    shared actual Whole divided(Whole other)
        =>  quotientAndRemainder(other).first;

    shared actual Whole remainder(Whole other)
        =>  quotientAndRemainder(other).last;

    "The result of raising this number to the given power.

     Special cases:

     * Returns one if `this` is one (or all powers)
     * Returns one if `this` is minus one and the power
       is even
     * Returns minus one if `this` is minus one and the
       power is odd
     * Returns one if the power is zero.
     * Otherwise negative powers result in an `Exception`
       being thrown"
    throws(`class Exception`, "If passed a negative or large
                               positive exponent")
    shared actual Whole power(Whole exponent) {
        if (this == package.one) {
            return this;
        }
        else if (exponent == package.zero) {
            return one;
        }
        else if (this == package.negativeOne && exponent.even) {
            return package.one;
        }
        else if (this == package.negativeOne && !exponent.even) {
            return this;
        }
        else if (exponent == package.one) {
            return this;
        }
        else if (exponent > package.one) {
            // TODO a reasonable implementation
            variable Whole result = this;
            for (_ in package.one..exponent-package.one) {
                result = result * this;
            }
            return result;
        }
        else {
            throw AssertionError(
                "``string``^``exponent`` cannot be represented as an Integer");
        }
    }

    shared actual Whole powerOfInteger(Integer exponent) {
        if (this == package.one) {
            return this;
        }
        else if (exponent == 0) {
            return one;
        }
        else if (this == package.negativeOne && exponent.even) {
            return package.one;
        }
        else if (this == package.negativeOne && !exponent.even) {
            return this;
        }
        else if (exponent == 1) {
            return this;
        }
        else if (exponent > 1) {
            // TODO a reasonable implementation
            variable Whole result = this;
            for (_ in 1..exponent-1) {
                result = result * this;
            }
            return result;
        }
        else {
            throw AssertionError(
                "``string``^``exponent`` cannot be represented as an Integer");
        }
    }

    "The result of `(this**exponent) % modulus`."
    throws(`class Exception`, "If passed a negative modulus")
    shared Whole powerRemainder(Whole exponent,
                                Whole modulus) => nothing;

    shared actual Whole neighbour(Integer offset)
        => plusInteger(offset);

    "The distance between this whole and the other whole"
    throws(`class OverflowException`,
        "The numbers differ by an amount larger than can be represented as an `Integer`")
    shared actual Integer offset(Whole other) {
        value diff = this - other;
        if (integerMin <= diff <= integerMax) {
            return diff.integer;
        }
        else {
            throw OverflowException();
        }
    }

    // TODO document 32 bit JS limit; nail down justification, including
    // asymmetry with wholeNumber(). No other amount seems reasonable.
    // JavaScript _almost_ supports 53 bits (1 negative number short),
    // but even so, 53 bits is not a convenient chunk to work with, and
    // is greater than the 32 bits supported for bitwise operations.
    "The number, represented as an [[Integer]]. If the number is too
     big to fit in an Integer then an Integer corresponding to the
     lower order bits is returned."
    shared Integer integer {
        if (exists integerMemo = integerMemo) {
            return integerMemo;
        } else {
            // result is lower runtime.integerAddressableSize bits of
            // the two's complement representation

            // for negative numbers, flip the bits and add 1
            variable Integer result = 0;
            // result should have up to integerAddressableSize bits (32 or 64)

            value count = runtime.integerAddressableSize/wordSize;

            variable value wordsIter = words.lowWord;
            variable value nonZeroSeen = false;
            for (i in 0:count) {
                Integer x;
                if (exists wordsCurr = wordsIter) {
                    if (negative) {
                        if (!nonZeroSeen) {
                            // negate the least significant non-zero
                            x = wordsCurr.word.negated;
                            nonZeroSeen = x != 0;
                        }
                        else {
                            // flip the rest
                            x = wordsCurr.word.not;
                        }
                    } else {
                        x = wordsCurr.word;
                    }
                    wordsIter = wordsCurr.nextHigher;
                } else {
                    x = if (negative) then -1 else 0;
                }
                value newBits = x.and(wordMask).leftLogicalShift(i * wordSize);
                result = result.or(newBits);
            }
            return integerMemo = result;
        }
    }

    "The number, represented as a [[Float]]. If the magnitude of this number
     is too large the result will be `infinity` or `-infinity`. If the result
     is finite, precision may still be lost."
    shared Float float {
        assert (exists f = parseFloat(string));
        return f;
    }

    shared actual Whole negated
        =>  if (zero) then
                package.zero
            else if (this.unit) then
                package.negativeOne
            else if (this == package.negativeOne) then
                package.one
            else Internal(sign.negated, words);

    shared actual Whole wholePart => this;

    shared actual Whole fractionalPart => package.zero;

    shared actual Boolean positive => sign == 1;

    shared actual Boolean negative => sign == -1;

    shared actual Boolean zero => sign == 0;

    shared actual Boolean unit => this == one;

    // TODO doc
    shared Boolean even
        =>  if (exists lowWord = words.lowWord)
            then lowWord.word.even
            else true;

    "The platform-specific implementation object, if any.
     This is provided for interoperation with the runtime
     platform."
    see(`function fromImplementation`)
    shared Object? implementation => nothing;  // TODO remove once decimal allows

    shared actual Integer hash {
        variable Integer result = 0;
        variable value wordIter = words.lowWord;
        while (exists wordCurr = wordIter) {
            result = result * 31 + wordCurr.word;
            wordIter = wordCurr.nextHigher;
        }
        return sign * result;
    }

    shared actual String string {
        // TODO optimize? & support any radix
        if (exists stringMemo = stringMemo) {
            return stringMemo;
        }
        else if (this.zero) {
            return stringMemo = "0";
        }
        else {
            // Use Integer once other fn's are optimized
            value toRadix = wholeNumber(10);
            value sb = StringBuilder();
            variable value x = this.magnitude;
            while (!x.zero) {
                value qr = x.quotientAndRemainder(toRadix);
                x = qr.first;
                sb.append (qr.last.integer.string);
            }
            if (negative) {
                sb.append("-");
            }
            return stringMemo = sb.string.reversed;
        }
    }

    shared actual Comparison compare(Whole other)
        =>  if (sign != other.sign) then
                sign.compare(other.sign)
            else if (zero) then
                equal
            else if (positive) then
                compareMagnitude(this.words, other.words)
            else
                compareMagnitude(other.words, this.words);

    shared actual Boolean equals(Object that)
        =>  if (is Whole that) then
                (this === that) ||
                (this.sign == that.sign &&
                 this.words == that.words)
            else
                false;

    WordList add(WordList first, WordList second) {
        // Knuth 4.3.1 Algorithm A
        value wMask = wordMask;
        value wSize = wordSize;

        WordList uList;
        WordList vList;
        if (first.size >= second.size) {
            uList = first;
            vList = second;
        } else {
            uList = second;
            vList = first;
        }

        value rList = wordListOfSize(uList.size);

        variable WordCell? uIter = uList.lowWord;
        variable WordCell? vIter = vList.lowWord;
        variable WordCell? rIter = rList.lowWord;
        variable value carry = 0;

        // add u's and v's
        while (exists vCurr = vIter) {
            assert(exists uCurr = uIter);
            assert(exists rCurr = rIter);
            value sum = uCurr.word + vCurr.word + carry;
            rCurr.word = sum.and(wMask);
            carry = sum.rightLogicalShift(wSize);
            vIter = vCurr.nextHigher;
            uIter = uCurr.nextHigher;
            rIter = rCurr.nextHigher;
        }

        // only u's remain
        while (carry != 0, exists uCurr = uIter) {
            assert(exists rCurr = rIter);
            value sum = uCurr.word + carry;
            rCurr.word = sum.and(wMask);
            carry = sum.rightLogicalShift(wSize);
            uIter = uCurr.nextHigher;
            rIter = rCurr.nextHigher;
        }

        // copy reamining u's, w/o carry
        while (exists uCurr = uIter) {
            assert(exists rCurr = rIter);
            rCurr.word = uCurr.word;
            uIter = uCurr.nextHigher;
            rIter = rCurr.nextHigher;
        }

        // remaining carry, if any
        if (carry != 0) {
            rList.addHighWord(carry);
        }

        return rList;
    }

    WordList subtract(WordList uList, WordList vList) {
        // Knuth 4.3.1 Algorithm S
        assert (uList.size >= vList.size);

        value wMask = wordMask;
        value wSize = wordSize;

        value rList = wordListOfSize(uList.size);
        variable WordCell? uIter = uList.lowWord;
        variable WordCell? vIter = vList.lowWord;
        variable WordCell? rIter = rList.lowWord;
        variable value borrow = 0;

        while (exists vCurr = vIter) {
            assert(exists uCurr = uIter);
            assert(exists rCurr = rIter);

            value difference = uCurr.word - vCurr.word + borrow;
            rCurr.word = difference.and(wMask);
            borrow = difference.rightArithmeticShift(wSize);

            uIter = uCurr.nextHigher;
            vIter = vCurr.nextHigher;
            rIter = rCurr.nextHigher;
        }

        // remaining u's
        while (borrow != 0, exists uCurr = uIter) {
            assert(exists rCurr = rIter);

            value difference = uCurr.word + borrow;
            rCurr.word = difference.and(wMask);
            borrow = difference.rightArithmeticShift(wSize);

            uIter = uCurr.nextHigher;
            rIter = rCurr.nextHigher;
        }

        // remaining u's w/o borrow
        while (exists uCurr = uIter) {
            assert(exists rCurr = rIter);

            rCurr.word = uCurr.word;

            uIter = uCurr.nextHigher;
            rIter = rCurr.nextHigher;
        }

        rList.normalize();
        return rList;
    }

    WordList multiply(WordList uList, WordList vList) {
        // Knuth 4.3.1 Algorithm M
        value wMask = wordMask;
        value wSize = wordSize;

        value rList = wordListOfSize(uList.size + vList.size);

        assert(exists uHead = uList.lowWord);
        assert(exists vHead = vList.lowWord);
        assert(exists rHead = rList.lowWord);

        // result is all zeros the first time through
        variable WordCell? rIter = rHead;
        variable WordCell? vIter = vHead;
        variable value carry = 0;
        value uLow = uHead.word;
        while (exists vCurr = vIter) {
            assert (exists rCurr = rIter);
            value product = uLow * vCurr.word + carry;
            rCurr.word = product.and(wMask);
            carry = product.rightLogicalShift(wSize);
            vIter = vCurr.nextHigher;
            rIter = rCurr.nextHigher;
        }
        assert (exists rCarry1 = rIter);
        rCarry1.word = carry;

        variable value uIter = uHead.nextHigher; // we already did the first one
        variable value rStart = rHead.nextHigher; // skip one on the results as well
        while (exists uCurr = uIter) {
            value uCurrWord = uCurr.word;
            carry = 0;
            vIter = vHead;
            rIter = rStart;
            while (exists vCurr = vIter) {
                assert (exists rCurr = rIter);
                value product = uCurrWord * vCurr.word + rCurr.word + carry;
                rCurr.word = product.and(wMask);
                carry = product.rightLogicalShift(wSize);
                vIter = vCurr.nextHigher;
                rIter = rCurr.nextHigher;
            }
            assert (exists rCarry2 = rIter);
            rCarry2.word = carry;
            uIter = uCurr.nextHigher;
            rStart = rStart?.nextHigher;
        }

        // normalize the result
        if (carry == 0) {
            rList.removeHighWord();
        }

        return rList;
    }

    WordList multiplyWord(
            WordList u, Integer v, WordList r = wordListOfSize(u.size)) {
        assert(v.and(wordMask) == v);

        value wMask = wordMask;

        variable value carry = 0;
        variable value uIter = u.lowWord;
        variable value rIter = r.lowWord;
        while (exists uCurr = uIter) {
            assert (exists rCurr = rIter);
            value product = uCurr.word * v + carry;
            rCurr.word = product.and(wMask);
            carry = product.rightLogicalShift(wordSize);
            uIter = uCurr.nextHigher;
            rIter = rCurr.nextHigher;
        }

        if (!carry.zero) {
            if (exists rCurr = rIter) {
                rCurr.word = carry;
                rIter = rCurr.nextHigher;
            }
            else {
                r.addHighWord(carry);
            }
        }

        // provided `r` may be larger than necessary
        while (exists rCurr = rIter) {
            rCurr.word = 0;
            rIter = rCurr.nextHigher;
        }

        return r;
    }

    "`u[j+1..j+vSize] <- u[j+1..j+vSize] - v * q`, returning the absolute value
     of the final borrow that would normally be subtracted against u[j]."
    Integer multiplyAndSubtract(WordCell uLow,
                                WordList v,
                                Integer q) {

        variable Integer absBorrow = 0;

        // put into a portion u the result of
        //      v*q subtracted from a portion of u
        // iterate low to high on u, need the cell for j+vSize to be passed in.

        variable WordCell? vIter = v.lowWord;
        variable WordCell? uIter = uLow;

        while (exists vCurr = vIter) {
            assert (exists uCurr = uIter);

            // the product is subtracted, so absBorrow adds to it
            value product = q * vCurr.word + absBorrow;
            value difference = uCurr.word - product.and(wordMask); // TODO wMask local
            uCurr.word = difference.and(wordMask);
            absBorrow = product.rightLogicalShift(wordSize) -
                        difference.rightArithmeticShift(wordSize);

            vIter = vCurr.nextHigher;
            uIter = uCurr.nextHigher;
        }

        return absBorrow;
    }

    [WordList, WordList] divide(WordList dividend, WordList divisor) {
        if (divisor.size < 2) {
            assert (exists cell = divisor.highWord);
            return (divideWord(dividend, cell.word));
        }

        // Knuth 4.3.1 Algorithm D

        // D1. Normalize
        // TODO: left shift such that v0 >= radix/2 instead of the times approach
        value m = dividend.size - divisor.size;
        value b = wordRadix;
        value d = b / (divisor.unsafeHighWord.word + 1);
        WordList u;
        WordList v;
        if (d == 1) {
            u = wordListCopy(dividend); // FIXME on other branch (was using words prop!!!)
            u.addHighWord(0);
            v = divisor;
        }
        else {
            // size of u will be the size of dividend + 1
            u = multiplyWord(dividend, d);
            // size of v will be the size of divisor
            v = multiplyWord(divisor, d);

            if (u.size == dividend.size) {
                u.addHighWord(0);
            }
        }
        WordList q = wordListOfSize(m + 1); // quotient
        value v0Cell = v.unsafeHighWord; // most significant, can't be 0
        value v1Cell = v0Cell.unsafeLower; // second most significant must also exist
        value v0 = v0Cell.word;
        value v1 = v1Cell.word;

        variable WordCell? uj0Iter = u.highWord;
        variable WordCell? qIter = q.highWord;

        // skip high words of u, so that the initial range of u-words
        // is large enough to divide by v
        variable WordCell? uIter = u.highWord;
        for (_ in 0:v.size) {
            uIter = uIter?.nextLower;
        }

        // D2. Initialize j
        while (exists uCurr = uIter) {
            assert (exists qCurr = qIter);
            assert (exists uj0Curr = uj0Iter);

            // D3. Compute qj
            value uj0 = uj0Curr.word;
            value uj1 = uj0Curr.unsafeLower.word;
            value uj2 = uj0Curr.unsafeLower.unsafeLower.word;

            value uj01 = uj0.leftLogicalShift(wordSize) + uj1;
            variable Integer qj;
            variable Integer rj;
            if (uj01 >= 0) {
                qj = uj01 / v0;
                rj = uj01 % v0;
            } else {
                value qrj = unsignedDivide(uj01, v0);
                qj = qrj.rightLogicalShift(wordSize);
                rj = qrj.and(wordMask);
            }

            while (qj >= b || unsignedCompare(qj * v1, b * rj + uj2) == larger) {
                // qj is too big
                qj -= 1;
                rj += v0;
                if (rj >= b) {
                    break;
                }
            }

            // D4. Multiply, Subtract
            if (qj != 0) {
                value borrow = multiplyAndSubtract(uCurr, v, qj);
                if (borrow != uj0) {
                    // assert borrow > uj0;
                    throw Exception("case not handled");
                }
                uj0Curr.word = 0;
                qCurr.word = qj;
            }

            // loop
            qIter = qCurr.nextLower;
            uIter = uCurr.nextLower;
            uj0Iter = uj0Curr.nextLower;
        }

        // D8. Unnormalize Remainder Due to Step D1
        u.normalize();
        variable value remainder = u;
        if (!u.size == 0 && d != 1) {
            remainder = divideWord(remainder, d).first;
        }
        return [q, remainder];
    }

    [WordList, WordList] divideWord(WordList u, Integer v) {
        assert(u.size >= 1);
        assert(v.and(wordMask) == v);

        variable value r = 0;
        value q = wordListOfSize(u.size);
        variable value uIter = u.highWord;
        variable value qIter = q.highWord;

        while (exists uCurr = uIter) {
            assert (exists qCurr = qIter);
            value x = r * wordRadix + uCurr.word;
            if (x >= 0) {
                qCurr.word = x / v;
                r = x % v;
            }
            else {
                value qr = unsignedDivide(x, v);
                qCurr.word = qr.rightLogicalShift(wordSize);
                r = qr.and(wordMask);
            }
            uIter = uCurr.nextLower;
            qIter = qCurr.nextLower;
        }
        return [q, if (r == 0)
                    then wordListOfSize(0)
                    else wordListOfOne(r)];
    }

    Whole leftLogicalShift(Integer shift) => nothing;

    Comparison compareMagnitude(WordList x, WordList y) {
        if (x.size != y.size) {
            return x.size <=> y.size;
        }
        else {
            variable value xIter = x.highWord;
            variable value yIter = y.highWord;
            while (exists xCurr = xIter) {
                assert (exists yCurr = yIter);
                if (xCurr.word != yCurr.word) {
                    return xCurr.word <=> yCurr.word;
                }
                xIter = xCurr.nextLower;
                yIter = yCurr.nextLower;
            }
            return equal;
        }
    }

}


/*
"The greatest common divisor of the arguments."
shared Whole gcd(Whole a, Whole b) {
    // TODO return Whole(a.val.gcd(b.val));
    throw;
}

"The least common multiple of the arguments."
shared Whole lcm(Whole a, Whole b) {
    return (a*b) / gcd(a, b);
}

"The factorial of the argument."
shared Whole factorial(Whole a) {
    if (a <= Whole(0)) {
        throw;
    }
    variable Whole b = a;
    variable Whole result = a;
    while (b >= Whole(2)) {
        b = b.predecessor;
        result *= b;
    }
    return result;
}
*/
