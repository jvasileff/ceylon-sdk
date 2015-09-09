import ceylon.collection {
    HashSet,
    unlinked,
    MutableSet
}
import ceylon.test {
    test,
    assertEquals
}

shared class HashSetTest() satisfies MutableSetTests & InsertionOrderIterableTests {

    shared actual MutableSet<Element> createSet<Element>({Element*} elements)
            given Element satisfies Object
        => HashSet { elements = elements; };

    createCategory = createSet<String>;
    createIterable = createSet<String>;

    test shared void elementsAreKeptInOrder() {
        value set = HashSet { "A", "B", "C" };

        assertEquals(set.first, "A");
        assertEquals(set.rest.first, "B");
        assertEquals(set.rest.rest.first, "C");
    }
    
    test shared void elementsAreRemovedFromLinkedList(){
        value set = createSet<String>{};
        set.add("a");
        set.add("b");
        set.remove("a");
        assertEquals(set.size, 1);
        assertEquals({ for (item in set) item }.sequence(), ["b"]);
    }
}

shared class UnlinkedHashSetTest() satisfies MutableSetTests & HashOrderIterableTests {

    shared actual MutableSet<Element> createSet<Element>({Element*} elements)
            given Element satisfies Object
        => HashSet { stability = unlinked; elements = elements; };

    createCategory = createSet<String>;
    createIterable = createSet<String>;

}
