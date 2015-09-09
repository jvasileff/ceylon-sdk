"A wrapper class that exposes any [[Set]] as unmodifiable, 
 hiding the underlying `Set` implementation from clients, 
 and preventing attempts to narrow to [[MutableSet]]."
by ("Gavin King")
class UnmodifiableSet<out Element>(Set<Element> set)
        satisfies Set<Element>
        given Element satisfies Object {
    
    iterator() => set.iterator();
    
    size => set.size;
    
    contains(Object element) => set.contains(element);
    
    shared actual Set<Element> complement<Other>(Set<Other> set)
            given Other satisfies Object 
            => this.set.complement(set);
    
    shared actual Set<Element|Other> exclusiveUnion<Other>(Set<Other> set)
            given Other satisfies Object 
            => this.set.exclusiveUnion(set);
    
    shared actual Set<Element> intersection<Other>(Set<Other> set)
            given Other satisfies Object 
            => this.set.intersection(set);
    
    shared actual Set<Element|Other> union<Other>(Set<Other> set)
            given Other satisfies Object 
            => this.set.union(set);
    
    superset(Set<Object> set) => this.set.superset(set);
    subset(Set<Object> set) => this.set.subset(set);
    
    equals(Object that) 
            => set.equals(that);
    hash => set.hash;
    
    clone() => UnmodifiableSet(set.clone());
    
    each(void step(Element element)) => set.each(step);
    
}

"Wrap the given [[Set]], preventing attempts to narrow the
 returned `Set` to [[MutableSet]]."
shared Set<Element> unmodifiableSet<Element>(Set<Element> set)
        given Element satisfies Object
        => UnmodifiableSet(set);
