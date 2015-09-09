import java.util {
    JSet=Set,
    HashSet
}

"A Ceylon [[Set]] that wraps a [[java.util::Set]]."
shared class CeylonSet<out Element>(JSet<out Element> set)
        extends CeylonCollection<Element>(set)
        satisfies Set<Element> 
        given Element satisfies Object {
    
    iterator() => CeylonIterator(set.iterator());
    
    contains(Object element) => set.contains(element);

    size => set.size();

    shared actual Set<Element> 
            complement<Other>(Set<Other> set)
            given Other satisfies Object {
        value complement = HashSet<Element>();
        for (e in this) {
            if (!set.contains(e)) {
                complement.add(e);
            }
        }
        return CeylonSet(complement);
    }
    
    shared actual Set<Element|Other> 
            exclusiveUnion<Other>(Set<Other> set)
            given Other satisfies Object {
        value exclusiveUnion = HashSet<Element|Other>();
        for (e in this) {
            if (!set.contains(e)) {
                exclusiveUnion.add(e);
            }
        }
        for (e in set) {
            if (!this.set.contains(e)) {
                exclusiveUnion.add(e);
            }
        }
        return CeylonSet(exclusiveUnion);
    }
    
    shared actual Set<Element> 
            intersection<Other>(Set<Other> set)
            given Other satisfies Object {
        value intersection = HashSet<Element>();
        for (e in this) {
            if (set.contains(e)) {
                intersection.add(e);
            }
        }
        return CeylonSet(intersection);
    }
    
    shared actual Set<Element|Other> 
            union<Other>(Set<Other> set)
            given Other satisfies Object {
        value union = HashSet<Element|Other>();
        for (e in this) {
            union.add(e);
        }
        for (e in set) {
            union.add(e);
        }
        return CeylonSet(union);
    }
    
    shared actual default Set<Element> clone()
            => CeylonSet(HashSet(set));
    
    equals(Object that) 
            => (super of Set<Element>).equals(that);
    
    hash => (super of Set<Element>).hash;
    
}