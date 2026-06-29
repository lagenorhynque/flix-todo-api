mod FlixToDoApi.TestToDo {
    use Assert.{assertEq, assertFalse, assertNeq, assertTrue}
    use FlixToDoApi.{ToDo => Sut}

    @Test
    def testMatchesWithTitleOrDetail_None(): Unit \ Assert =
        let toDo = incompleteToDo();
        assertTrue(Sut.matchesWithTitleOrDetail(None, toDo))

    @Test
    def testMatchesWithTitleOrDetail_Some(): Unit \ Assert =
        let toDo = incompleteToDo();
        assertTrue(Sut.matchesWithTitleOrDetail(Some("書"), toDo));
        assertTrue(Sut.matchesWithTitleOrDetail(Some("FP"), toDo));
        assertTrue(Sut.matchesWithTitleOrDetail(Some("読"), toDo));
        assertFalse(Sut.matchesWithTitleOrDetail(Some("買"), toDo))

    @Test
    def testMatchesWithIsDone_None(): Unit \ Assert =
        assertTrue(Sut.matchesWithIsDone(None, incompleteToDo()));
        assertTrue(Sut.matchesWithIsDone(None, completedToDo()))

    @Test
    def testMatchesWithIsDone_Some(): Unit \ Assert =
        assertFalse(Sut.matchesWithIsDone(Some(true), incompleteToDo()));
        assertTrue(Sut.matchesWithIsDone(Some(true), completedToDo()));
        assertTrue(Sut.matchesWithIsDone(Some(false), incompleteToDo()));
        assertFalse(Sut.matchesWithIsDone(Some(false), completedToDo()))

    @Test
    def testComplete_incomplete(): Unit \ Assert =
        let Sut.ToDo({id = idBefore, title = titleBefore, detail = detailBefore, isDone = isDoneBefore}) = incompleteToDo();
        let Sut.ToDo({id = idAfter, title = titleAfter, detail = detailAfter, isDone = isDoneAfter}) = Sut.complete(incompleteToDo());
        assertEq(expected = idBefore, idAfter);
        assertEq(expected = titleBefore, titleAfter);
        assertEq(expected = detailBefore, detailAfter);
        assertNeq(unexpected = isDoneBefore, isDoneAfter)

    @Test
    def testComplete_completed(): Unit \ Assert =
        assertEq(expected = completedToDo(), Sut.complete(completedToDo()))

    def incompleteToDo(): Sut.ToDo =
        Sut.ToDo({
            id = Sut.ToDoId(1),
            title = "読書",
            detail = "FP in Scalaを読む",
            isDone = false
        })

    def completedToDo(): Sut.ToDo =
        Sut.ToDo({
            id = Sut.ToDoId(2),
            title = "プログラミング",
            detail = "Flixプログラムを書く",
            isDone = true
        })
}
